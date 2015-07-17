//
//  HMMenuViewController.swift
//  HamburgerMenu
//
//  Created by Yescas, Francisco on 7/17/15.
//  Copyright (c) 2015 Francisco Bernal Yescas. All rights reserved.
//

import UIKit

enum HMCellMenuAnimation : Int {
    case None
    case SlideInAnimation
    case SlideInWithBounceAnimation
}

enum HMMenuRotationBehavior : Int {
    case None
    case Close
    case SetWindowColorBackground
}

@objc protocol HMMenuViewControllerDelegate: NSObjectProtocol {
    func setNewViewController (navController:UINavigationController, fromIndexPath indexPath:NSIndexPath)
    optional func didShowMenu (menu:HMMenuViewController,  inViewController viewController:UIViewController);
    optional func didCloseMenu (menu:HMMenuViewController);
}

class HMMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: UIButton!
    
    var delegate: HMMenuViewControllerDelegate?
    var cellMenuAnimation:HMCellMenuAnimation = .SlideInAnimation
    var rotationBehavior:HMMenuRotationBehavior = .SetWindowColorBackground
    var containerViewBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    
    private let images:NSArray
    private let titles:NSArray
    private let closeImageButton:UIImage
    
    private var doneAnimations = false
    private var doneCellAnimations = false
    private var orientation = UIDeviceOrientation.Unknown
    private var currentController:UIViewController?
    private var viewBackgroundColor:UIColor { // ??? refactor needed
        if let navigationController = HMViewControllerManager.sharedInstance.navigationController {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
            navigationController.view.drawViewHierarchyInRect(navigationController.view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIColor(patternImage: image)
        }
        return UIColor.whiteColor()
    }
    
    // MARK: - Initializers
    
    init () {
        self.images = HMViewControllerManager.sharedInstance.images!
        self.titles = HMViewControllerManager.sharedInstance.titles!
        self.closeImageButton = HMViewControllerManager.sharedInstance.closeMenuButtonImage!
        super.init(nibName: nil, bundle: nil)
    }
    
    init (images:NSArray, titles:NSArray, closeImageButton:UIImage) {
        self.images = images
        self.titles = titles
        self.closeImageButton = closeImageButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.images = HMViewControllerManager.sharedInstance.images!
        self.titles = HMViewControllerManager.sharedInstance.titles!
        self.closeImageButton = HMViewControllerManager.sharedInstance.closeMenuButtonImage!
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = UIColor.whiteColor()
        
        // closeButton setup
        if closeButton == nil {
            closeButton = UIButton.buttonWithType(.Custom) as? UIButton
            closeButton.frame = CGRectMake(15, 20, 30, 30)
        }
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.setImage(closeImageButton, forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        closeButton.addTarget(self, action: Selector("closeMenuFromController:"), forControlEvents:.TouchUpInside)
        
        //tableview setup
        if tableView == nil {
            tableView = UITableView(frame: CGRectMake(0, 70, view.frame.size.width, view.frame.size.height-70), style:.Plain)
        }
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.bounces = false
        tableView.scrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        
        // containerView setup
        if containerView ==   nil {
            containerView = UIView(frame: view.frame)
            containerView.addSubview(tableView)
            containerView.addSubview(closeButton)
            view.addSubview(containerView)
        }
        containerView.backgroundColor = containerViewBackgroundColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("didRotate:"), name:"UIDeviceOrientationDidChangeNotification" , object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Rotation Methods
    
    @objc private func didRotate (notification: NSNotification ) {
        let orientation = UIDevice.currentDevice().orientation
        
        var rotationBehavior:HMMenuRotationBehavior = .None
        if ((self.orientation == .Portrait &&
            (orientation == .PortraitUpsideDown ||
                orientation == .LandscapeLeft ||
                orientation == .LandscapeRight)) ||
            (orientation == .Portrait &&
                (self.orientation == .PortraitUpsideDown ||
                    self.orientation == .LandscapeLeft ||
                    self.orientation == .LandscapeRight))) {
                        rotationBehavior = self.rotationBehavior
        }
        
        switch rotationBehavior {
        case .Close:
            closeMenuFromController(self);
            
        case .SetWindowColorBackground:
            if let window = UIApplication.sharedApplication().delegate?.window {
                self.view.backgroundColor = window?.backgroundColor
            }
            
        default:
            view.backgroundColor = self.viewBackgroundColor
        }
    }
    
    // MARK: - Show & Close menu
    
    func showMenuFromController (viewController: UIViewController) {
        if doneAnimations {
            return;
        }
        
        if let navigationController = HMViewControllerManager.sharedInstance.navigationController {
            doneCellAnimations =  false
            UIView.animateWithDuration(0.15, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
                viewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6)
                }) { (finished) -> Void in
                    self.currentController = viewController
                    self.orientation = UIDevice.currentDevice().orientation
                    self.view.backgroundColor = self.viewBackgroundColor
                    self.doneAnimations = true
                    self.containerView.alpha = 0.0
                    
                    navigationController.presentViewController(self, animated: false, completion: { () -> Void in
                        UIView.animateWithDuration(0.15, delay:0.0, options:.CurveEaseInOut, animations: { () -> Void in
                            self.containerView.alpha = 1.0
                            self.tableView.reloadData()
                            }, completion: { (finished) -> Void in
                                if self.delegate?.respondsToSelector(Selector("didShowMenu:inViewController:")) == true {
                                    self.delegate?.didShowMenu!(self, inViewController: viewController)
                                }
                        })
                    })
            }
        } else {
            fatalError("HMViewControllerManager.sharedInstance.navigationController has not been set")
        }
    }
    
    func closeMenuFromController (viewController:UIViewController) {
        if !doneAnimations {
            return
        }
        
        UIView.animateWithDuration(0.3/1.5, delay:0.0, usingSpringWithDamping:1.0, initialSpringVelocity:1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
            self.currentController?.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
            }) { (finished) -> Void in
                self.doneAnimations = false
                HMViewControllerManager.sharedInstance.navigationController?.dismissViewControllerAnimated(false, completion: { () -> Void in
                    self.currentController?.dismissViewControllerAnimated(false, completion: nil)
                    if self.delegate?.respondsToSelector(Selector("didCloseMenu:")) == true {
                        self.delegate?.didCloseMenu!(self)
                    }
                })
        }
    }
    
    // MARK: - UITableView Delegate & Datasource
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if doneCellAnimations {
            return
        }
        
        switch cellMenuAnimation {
        case .SlideInAnimation:
            performSlideInCellAnimationsWithCell(cell, forRowIndexPath: indexPath)
            
        case .SlideInWithBounceAnimation:
            performSlideInWithBounceCellAnimationsWithCell(cell, forRowIndexPath: indexPath)
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style:.Default, reuseIdentifier: cellIdentifier)
        }
        cell?.selectionStyle = .None
        cell?.backgroundColor = UIColor.clearColor()
        cell?.textLabel?.backgroundColor = UIColor.clearColor()
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.textAlignment = .Left
        cell?.imageView?.image = images.objectAtIndex(indexPath.row) as? UIImage
        cell?.textLabel?.text = titles.objectAtIndex(indexPath.row) as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        closeMenuFromController(self)
        delegate?.setNewViewController(HMViewControllerManager.sharedInstance.navigationController!, fromIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    // MARK: - Cell animations
    
    private func performSlideInCellAnimationsWithCell (cell:UITableViewCell, forRowIndexPath indexPath:NSIndexPath) {
        let oldFrame = cell.frame
        let newFrame = CGRectMake(-cell.frame.size.width, cell.frame.origin.y, 0, cell.frame.size.height)
        
        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.0001);
        cell.frame = newFrame
        cell.alpha = 0
        
        UIView.animateWithDuration(0.3/1.5, delay:0.1*Double(indexPath.row), usingSpringWithDamping: 0.7, initialSpringVelocity:1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
            cell.frame = oldFrame
            cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.0)
            cell.alpha = 1.0
            }) { (finished) -> Void in
                if self.tableView.numberOfRowsInSection(0) == indexPath.row+1 {
                    self.doneCellAnimations = true
                }
        }
    }
    
    private func performSlideInWithBounceCellAnimationsWithCell (cell:UITableViewCell, forRowIndexPath indexPath:NSIndexPath) {
        let oldFrame = cell.frame
        let newFrame = CGRectMake(-cell.frame.size.width, cell.frame.origin.y, 0, cell.frame.size.height)
        
        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.0001)
        cell.frame = newFrame
        
        UIView.animateWithDuration(0.1, delay:0.2*Double(indexPath.row), usingSpringWithDamping:1.0, initialSpringVelocity:1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
            cell.frame = oldFrame;
            cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.1)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, delay:0, options:.CurveEaseIn, animations: { () -> Void in
                    cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.9)
                    }, completion: { (finished) -> Void in
                        UIView.animateWithDuration(0.1, delay:0, options:.CurveEaseIn, animations: { () -> Void in
                            cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                            }, completion: { (finished) -> Void in
                                if self.tableView.numberOfRowsInSection(0) == indexPath.row+1 {
                                    self.doneCellAnimations = true
                                }
                        })
                })
        }
    }
    
}
