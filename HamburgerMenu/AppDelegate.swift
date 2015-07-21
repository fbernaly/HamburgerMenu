//
//  AppDelegate.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window?.backgroundColor = UIColor.whiteColor()
    
        if let navigationController = window?.rootViewController as? HMNavigationController {
            navigationController.transparency = true
        }
        
        let manager = HMViewControllerManager.sharedInstance
        manager.hamburgerMenuButtonImage = UIImage(named: "hamburgerMenuIcon")!
        manager.closeMenuButtonImage = UIImage(named: "closeIcon")!
        manager.titles = ["Home",
            "Ampersand",
            "Aperture",
            "Article",
            "At",
            "Bars",
            "Battery",
            "Bolt",
            "Book",
            "Equalizer",
            "Headphones",
            "iPhone",
            "Keys",
            "Layers",
            "Lock",
            "Mic",
            "Movies",
            "Paperclip",
            "Pen"]
        manager.images = [UIImage(named: "home")!,
            UIImage(named: "ampersand")!,
            UIImage(named: "aperture")!,
            UIImage(named: "article")!,
            UIImage(named: "at")!,
            UIImage(named: "bars")!,
            UIImage(named: "batteryCharging")!,
            UIImage(named: "bolt")!,
            UIImage(named: "book")!,
            UIImage(named: "equalizer")!,
            UIImage(named: "headphones")!,
            UIImage(named: "iphone")!,
            UIImage(named: "key")!,
            UIImage(named: "layers")!,
            UIImage(named: "lock")!,
            UIImage(named: "mic")!,
            UIImage(named: "movie")!,
            UIImage(named: "paperclip")!,
            UIImage(named: "pen")!]
        // HMMenuViewController NO using Storyboard
        // manager.menuViewController = HMMenuViewController()
        // HMMenuViewController using Storyboard
        manager.menuViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuController") as! HMMenuViewController
        if let navigationController = window?.rootViewController as? UINavigationController {
            manager.navigationController = navigationController
            manager.viewControllers = NSArray(objects: navigationController.viewControllers.first!,
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller2"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller3"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller4"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller5"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller1"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller2"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller3"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller4"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller5"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller1"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller2"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller3"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller4"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller5"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller1"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller2"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller3"),
                UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("Controller4"))
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

