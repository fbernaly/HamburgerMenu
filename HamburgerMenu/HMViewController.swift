//
//  HMViewController.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMViewController: UIViewController {
    
    var hamburgerMenuButtonImage: UIImage? {
        didSet {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image:hamburgerMenuButtonImage, style:.Plain, target:self, action:"showMenu")
            navigationItem.leftBarButtonItem?.tintColor = UIColor.blueColor()
        }
    }
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hamburgerMenuButtonImage = HMViewControllerManager.sharedInstance.hamburgerMenuButtonImage
    }

    // MARK: - Navigation helper functions
    
    func showMenu () {
        
    }
}
