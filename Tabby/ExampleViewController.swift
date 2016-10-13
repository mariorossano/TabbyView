//
//  ViewController.swift
//  Tabby
//
//  Created by mario rossano on 15/07/16.
//  Copyright © 2016 mario rossano. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController, TabbyViewDataSource, TabbyViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tabbyView: TabbyView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var data = ["cat", "dog", "crocodile", "rabbit", "bird"]
    
    var silentScroll = false
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabbyView.dataSource = self
        tabbyView.delegate = self
    
        scrollView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        _fill()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        scrollView.contentSize = CGSize(width: CGFloat(data.count) * scrollView.frame.width , height: scrollView.frame.height)
        
        
    }
    
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        silentScroll = true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        silentScroll = false
    }
    
    // MARK: fill scrollView
    
    func _fill() {
    
        for i in 0..<data.count {
            
            let item = data[i]
            
            let label = UILabel(frame:CGRect(x: CGFloat(i) * view.frame.width,y: 0,width: view.frame.width, height: view.frame.height - tabbyView.frame.height))
            
            label.text = "\(item)"
            
            label.textAlignment = NSTextAlignment.center
            label.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            
            label.layer.borderColor = UIColor.black.cgColor
            label.layer.borderWidth = 1.0
    
            scrollView.addSubview(label);
            
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(data.count) * view.frame.width , height: view.frame.height - 128)

    }
    
    
    // MARK: tabbyView dataSource
    
    func tabbyViewDataSourceGetNumberOfItems(tabbyBiew: TabbyView) -> Int {

        
        return data.count
        
    }
    

    func tabbyViewDataSourceGetViewByPosition(position: Int) -> UIView {
        
        // MARK: TabbyTitleViewProtocol implementation
        
        class MonthTabbyTitleView: UIView, TabbyItemViewProtocol {
            
            func highlight() {
                
                viewWithTag(13)?.alpha = 1.0
                
            }
            
            func unhighlight() {
                
                viewWithTag(13)?.alpha = 0.2
                
            }
            
        }
        
        let fontItem = tabbyView.fontItem ?? (UIFont(name: "HelveticaNeue", size: 20.0))
        let paddingItem = tabbyView.paddingItem
        
        let label = UILabel()
        label.font = fontItem
        label.tag = 13
        label.text = "\(data[position])"
        label.sizeToFit()
        
        let tabbyHeight = CGFloat(138.0)
        
        let titleView = MonthTabbyTitleView(frame: CGRect(x: 0, y: 0.0, width: label.frame.width + paddingItem * 2.0, height: tabbyHeight))
        
        label.frame.origin.x = paddingItem
        label.frame.origin.y = (tabbyHeight - label.frame.height) / 2.0
        
        titleView.addSubview(label)

        return titleView
        
    }
    
    // MARK: tabbyView delegate
    
    func tabbyViewDidEndDecelerating(tabbyBiew tabbyView:  TabbyView) { }
    
    func tabbyViewDidScroll(tabbyBiew: TabbyView) {
        
        let percentage = tabbyBiew.percentage
        
        silentScroll = true
        
        scrollView.setContentOffset(CGPoint(x: percentage * view.frame.width, y: 0), animated: false)
        
        silentScroll = false
        
    }
    
    // MARK: scrollView delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if silentScroll {
            return
        }
        
        let percentage = scrollView.contentOffset.x / scrollView.frame.width
        
        tabbyView.scroll(p: percentage)
        

    }
    

}

