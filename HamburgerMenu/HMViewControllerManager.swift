//
//  HMViewControllerManager.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMViewControllerManager: NSObject {
    
    static let sharedInstance = HMViewControllerManager()
    
    var menuViewController:UIViewController?
    var hamburgerMenuButtonImage:UIImage?
    var closeMenuButtonImage:UIImage?
    var setTitlesToViewControllers = true
    
    var images:NSArray? {
        didSet {
            checkTitlesAndImages()
        }
    }
    
    var titles:NSArray? {
        didSet {
            checkTitlesAndImages()
            checkTitlesAndViewControllers()
        }
    }
    
    var viewControllers:NSArray? {
        didSet {
            checkTitlesAndViewControllers()
        }
    }
    
    private func checkTitlesAndImages () {
        if images != nil && titles != nil && images?.count != titles?.count {
            println("Setting HMViewControllerManager with different number of images and titles.")
        }
    }
    
    private func checkTitlesAndViewControllers () {
        if viewControllers != nil && titles != nil && viewControllers?.count != titles?.count {
            println("Setting HMViewControllerManager with different number of view controllers and titles.")
        } else {
            if setTitlesToViewControllers {
                for title in titles! {
                    if let index = titles?.indexOfObject(title) {
                        if let viewController = viewControllers?.objectAtIndex(index) as? UIViewController {
                            viewController.title = title as? String
                        }
                    }
                }
            }
        }
    }
    
}
