//
//  HMViewController.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMViewController: UIViewController, HMMenuViewControllerDelegate {
    
    var hamburgerMenuButtonImage: UIImage? {
        didSet {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image:hamburgerMenuButtonImage, style:.Plain, target:self, action:"showMenuViewController")
            navigationItem.leftBarButtonItem?.tintColor = UIColor.blueColor()
        }
    }
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hamburgerMenuButtonImage = HMViewControllerManager.sharedInstance.hamburgerMenuButtonImage
    }

    // MARK: - Navigation helper functions
    
    func showMenuViewController () {
        if let menuController = HMViewControllerManager.sharedInstance.menuViewController as? HMMenuViewController {
            menuController.delegate = self
            menuController.showMenuFromController(self)
        }
    }
    
    func menuViewController (menuViewController:HMMenuViewController, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        if indexPath.row < HMViewControllerManager.sharedInstance.viewControllers?.count {
            if let viewController = HMViewControllerManager.sharedInstance.viewControllers?.objectAtIndex(indexPath.row) as? UIViewController {
                navigationController?.viewControllers = [viewController]
            }
        }
    }
}
