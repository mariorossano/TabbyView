//
//  TabbyView.swift
//  ReactTabby
//
//  Created by mario rossano on 29/09/16.
//  Copyright © 2016 Mario Rossano. All rights reserved.
//


import Foundation
import UIKit

enum TabbyViewAlign {
    case Left, Center
}

protocol TabbyItemViewProtocol {
    func highlight()
    func unhighlight()
}

@objc protocol TabbyViewDataSource {
    
    func tabbyViewDataSourceGetViewByPosition(position:Int) -> UIView
    
    func tabbyViewDataSourceGetNumberOfItems(tabbyBiew: TabbyView) -> Int
}

protocol TabbyViewDelegate {
    func tabbyViewDidScroll(tabbyBiew: TabbyView)
    func tabbyViewDidEndDecelerating(tabbyBiew: TabbyView)
    
}


@objc(TabbyView)
class TabbyView: UIView, UIScrollViewDelegate {
    
    var tabbyAlign: TabbyViewAlign?
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    var colorItem: UIColor = UIColor.clear
    
    var fontItem = UIFont(name: "HelveticaNeue", size: 20.0)
    
    @IBInspectable
    var fontName: String = "HelveticaNeue" {
        didSet {
            fontItem = UIFont(name: fontName, size: fontSize)
        }
    }
    
    @IBInspectable
    var fontSize: CGFloat = 20.0 {
        didSet {
            fontItem = UIFont(name: fontName, size: fontSize)
        }
    }
    
    @IBInspectable
    var paddingItem: CGFloat = 3.0
    
    var silentScroll = false
    
    var percentage = CGFloat(0.0)
    var page = 0
    
    var titleViews = [UIView]()
    
    var dataSource: TabbyViewDataSource? {
        didSet {
            loadPages()
            scrollViewDidScroll(scrollView)
            
        }
    }
    
    var delegate: TabbyViewDelegate?
    
    let scrollViewWidth = CGFloat(100.0)
    
    let scrollView = UIScrollView()
    let wrapperView = UIView()
    let scrollViewPlaceholderView = UIView()
    
    var currentWidth = CGFloat(0.0)
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setup()
        
    }
    
    func setup() {
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(
            tap(recognizer: )))
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        
        addGestureRecognizer(scrollView.panGestureRecognizer)
        
        wrapperView.addGestureRecognizer(tapGestureRecognizer!)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.addSubview(scrollViewPlaceholderView)
        
        addSubview(scrollView)
        addSubview(wrapperView)
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        scrollView.frame = CGRect(x:frame.width / 2 - scrollViewWidth / 2, y:CGFloat(0.0), width:scrollViewWidth, height:frame.height)
        
        wrapperView.frame = CGRect(x:0.0, y:0.0, width:currentWidth, height:frame.height)
        
        scrollViewPlaceholderView.frame = CGRect(x:CGFloat(0.0), y:CGFloat(0.0), width:CGFloat(dataSource?.tabbyViewDataSourceGetNumberOfItems(tabbyBiew: self) ?? 0) * scrollViewWidth, height:frame.height)
        
        scrollView.contentSize = CGSize(width: scrollViewPlaceholderView.frame.width, height: CGFloat(scrollView.frame.height))
        
        
        scrollViewDidScroll(scrollView)
        
    }

    func loadPages() {
        
        if let nitems = dataSource?.tabbyViewDataSourceGetNumberOfItems(tabbyBiew: self) {
            
            for i in 0 ..< nitems {
                
                if let titleView = dataSource?.tabbyViewDataSourceGetViewByPosition(position: i) {
                    titleView.translatesAutoresizingMaskIntoConstraints = false
                    
                    titleView.frame.origin.x = currentWidth
                    
                    titleViews.append(titleView)
                    
                    currentWidth += titleView.frame.width
                    
                    wrapperView.addSubview(titleView)
                    
                    setNeedsDisplay()
                }
            }
            
        }
        
    }
    
    
    func goToPage(page:Int) {
        
        percentage = CGFloat(page)
        
        silentScroll = true
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIViewAnimationOptions.beginFromCurrentState], animations: {
            
            self.scrollView.contentOffset.x = self.percentage * self.scrollViewWidth
            
        }) { (complete) in
            
            if complete {
                
            } else {
                
            }
            
            self.silentScroll = false
        }
        
    }

    func scroll(p:CGFloat) {
        
        silentScroll = true
        
        self.percentage = p
        self.scrollView.setContentOffset(CGPoint(x:self.percentage * self.scrollViewWidth, y:0), animated: false)
        
        silentScroll = false
        
    }

    
    func highlightCurrentTitleView() {
        
        for (index, titleView) in titleViews.enumerated() {
            
            if (CGFloat(index) >= percentage - 0.5 && CGFloat(index) <= percentage + 0.5) || (index == 0 && percentage <= 0.5) || (index == titleViews.count - 1 && page >= titleViews.count - 1) {
                
                if let tabbytitleView = titleView as? TabbyItemViewProtocol {
                    
                    tabbytitleView.highlight()
                    
                }
                
                
            } else {
                
                if let tabbytitleView = titleView as? TabbyItemViewProtocol {
                    
                    tabbytitleView.unhighlight()
                    
                }
                
            }
            
        }
    }
    
    func tap(recognizer : UITapGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            let point = recognizer.location(in: wrapperView)
            
            for (index, titleView) in titleViews.enumerated() {
                
                if titleView.frame.contains(point) {
                    
                    scrollView.setContentOffset(CGPoint(x: (scrollViewWidth * CGFloat(index)) ,y: 0.0), animated: true)
                    
                }
                
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let align = tabbyAlign ?? TabbyViewAlign.Center
        
        if(titleViews.count <= 0) {
            return
        }
        
        tapGestureRecognizer!.isEnabled = false
        
        let offset = scrollView.contentOffset.x
        
        percentage = offset / scrollViewWidth
        page = Int(floor(Float(percentage)))
        
        var p = fmod(percentage, CGFloat(page))
        
        if(page == 0) {
            p = percentage
        }
        
        highlightCurrentTitleView()
        
        if(!silentScroll){
            delegate?.tabbyViewDidScroll(tabbyBiew: self)
        }
        
        if(page < 0) {

            switch align {
            case .Center:
                wrapperView.frame.origin.x = frame.width / 2 - titleViews.first!.frame.width / 2 - offset
            case .Left:
                wrapperView.frame.origin.x =  -offset
            }
            
        }
        
        if page >= titleViews.count - 1 {
            
            let relativeOffset = offset - CGFloat(page) * scrollViewWidth
            
            switch align {
            
            case .Center:
            
                wrapperView.frame.origin.x = -(wrapperView.frame.width - titleViews.last!.frame.width / 2) + frame.width/2 - relativeOffset
                
            case .Left:
                
                wrapperView.frame.origin.x = -(wrapperView.frame.width - titleViews.last!.frame.width) - relativeOffset
                
            }
            
        }
        
        if page >= 0 && page < titleViews.count - 1 {
            
            var itemX = CGFloat(0.0)
            
            for i in (0...page) {
                
                let titleView = titleViews[i]
                
                itemX += titleView.frame.width
                
            }
            
            let prevTitleView = titleViews[page]
            let nextTitleView = titleViews[page + 1]
            
            switch align {
            
            case .Center:
                
                itemX -= (prevTitleView.frame.width / 2)
                let distance = (prevTitleView.frame.width / 2) + (nextTitleView.frame.width / 2)
                itemX += (p * distance)
                wrapperView.frame.origin.x = -itemX + frame.width / 2
                
            case .Left:
                
                itemX -= prevTitleView.frame.width
                let distance = prevTitleView.frame.width
                itemX += (p * distance)
                wrapperView.frame.origin.x = -itemX
                
            }
            
        }
        
        tapGestureRecognizer!.isEnabled = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !silentScroll {
            
            delegate?.tabbyViewDidEndDecelerating(tabbyBiew: self)
            
        }
        
    }
    
}
