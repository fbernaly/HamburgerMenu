//
//  HMNavigationController.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMNavigationController: UINavigationController, UINavigationControllerDelegate {

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
        
        delegate = self
    }
    
    // MARK: Delegate Methods
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        viewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
        
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:.CurveEaseIn, animations: { () -> Void in
            viewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        }, completion: nil)
        
    }

}
