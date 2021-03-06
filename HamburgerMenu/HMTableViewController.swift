//
//  HMTableViewController.swift
//  HamburgerMenu
//
//  Created by Francisco Bernal Yescas on 7/16/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

class HMTableViewController: UITableViewController, HMMenuViewControllerDelegate {
    
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
