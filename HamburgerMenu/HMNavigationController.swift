//
//  HMNavigationController.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMNavigationController: UINavigationController {

    var transparency:Bool = false {
        didSet {
            if transparency {
                // make the navigation bar transparent
                
                navigationBar.setBackgroundImage(UIImage(), forBarMetrics:.Default)
                navigationBar.shadowImage = UIImage()
                navigationBar.translucent = true
                navigationBar.backgroundColor = UIColor.clearColor()
                view.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    // MARK: Initializer
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
