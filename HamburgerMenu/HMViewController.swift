//
//  HMViewController.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMViewController: UIViewController {
    
    var hamburgerMenuIconImage: UIImage? = UIImage(named: "hamburgerMenuIcon") {
        didSet {
            setupLeftBarButtonItem()
        }
    }
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLeftBarButtonItem()
    }

    // MARK: - Navigation helper functions
    
    func showMenu () {
        
    }
    
    func setupLeftBarButtonItem () {
        // setting up menu bar button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:hamburgerMenuIconImage, style:.Plain, target:self, action:"showMenu")
        navigationItem.leftBarButtonItem?.tintColor = UIColor.blueColor()
    }
}
