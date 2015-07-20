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

@objc protocol HMMenuViewControllerDelegate: NSObjectProtocol {
    func setNewViewController (navController:UINavigationController, fromIndexPath indexPath:NSIndexPath)
    optional func didShowMenu (menu:HMMenuViewController,  inViewController viewController:UIViewController);
    optional func didCloseMenu (menu:HMMenuViewController);
}

class HMMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var blurEffectView: UIVisualEffectView!
    
    var delegate: HMMenuViewControllerDelegate?
    var cellMenuAnimation:HMCellMenuAnimation = .SlideInAnimation
    var slideContainerView = true
    var animateCellMenuTap = true
    var maxContainerViewWidth:CGFloat = 200
    
    private let images:NSArray
    private let titles:NSArray
    private let closeImageButton:UIImage
    private let minContainerViewWidth:CGFloat = 10
    
    private var doneAnimations = false
    private var doneCellAnimations = false
    private var orientation = UIDeviceOrientation.Unknown
    private var currentController:UIViewController?
    private var frame:CGRect?
    
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
        
        // view setup
        view.backgroundColor = UIColor.clearColor()
        view.tintColor = UIColor.whiteColor()
        
        // ViewController setup
        modalPresentationStyle = .OverCurrentContext
        
        // blurEffectView setup
        if blurEffectView == nil {
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
            blurEffectView.frame = view.bounds
            blurEffectView.alpha = 0.7
            view.addSubview(blurEffectView)
        }
        
        // closeButton setup
        if closeButton == nil {
            closeButton = UIButton.buttonWithType(.Custom) as? UIButton
        }
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.setImage(closeImageButton, forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        closeButton.addTarget(self, action: Selector("closeMenuFromController:"), forControlEvents:.TouchUpInside)
        
        //tableview setup
        if tableView == nil {
            tableView = UITableView()
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
        containerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
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
        currentController?.view.transform  = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            if ((self.orientation == .Portrait &&
                (orientation == .PortraitUpsideDown ||
                    orientation == .LandscapeLeft ||
                    orientation == .LandscapeRight)) ||
                (orientation == .Portrait &&
                    (self.orientation == .PortraitUpsideDown ||
                        self.orientation == .LandscapeLeft ||
                        self.orientation == .LandscapeRight))) {
                            if let frame = self.frame {
                                self.currentController?.view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width)
                            }
            } else {
                self.currentController?.view.frame = frame!
            }
        } else {
            if (((self.orientation == .Portrait ||
                self.orientation == .PortraitUpsideDown) &&
                (orientation == .LandscapeLeft ||
                    orientation == .LandscapeRight)) ||
                ((orientation == .Portrait ||
                    orientation == .PortraitUpsideDown) &&
                    (self.orientation == .LandscapeLeft ||
                        self.orientation == .LandscapeRight))) {
                            if let frame = self.frame {
                                self.currentController?.view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width)
                            }
            } else {
                self.currentController?.view.frame = frame!
            }
        }
        currentController?.view.transform  = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6)
        
        if let containerViewWidthConstraint = self.containerViewWidthConstraint {
            if !slideContainerView {
                containerViewWidthConstraint.constant = UIScreen.mainScreen().bounds.width + 20
                view.layoutIfNeeded()
            }
        } else {
            updateFrames()
        }
    }
    
    @objc private func updateFrames () {
        var closeButtonOriginY:CGFloat = 26
        var tableViewFrameY:CGFloat = 55
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone && !((UIDevice.currentDevice().orientation == orientation && (UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown)) || UIDevice.currentDevice().orientation == .Portrait) {
            closeButtonOriginY = 0
            tableViewFrameY = 30
        }
        
        //updating closeButton frame
        closeButton.frame = CGRectMake(UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 13 : 17, closeButtonOriginY, 30, 30)
        
        //updating containerView frame
        if self.slideContainerView {
            containerView.frame = CGRectMake(0, 0, doneAnimations ? maxContainerViewWidth : minContainerViewWidth, view.frame.size.height)
        } else {
            containerView.frame = view.frame
        }
        
        //updating blurEffectView frame
        blurEffectView.frame = view.frame
        
        //updating tableView frame
        tableView.frame =  CGRectMake(0, tableViewFrameY, view.frame.size.width, view.frame.size.height-tableViewFrameY)
    }

    // MARK: - Show & Close menu

    func showMenuFromController (viewController: UIViewController) {
        if doneAnimations {
            return;
        }
        
        currentController = viewController
        orientation = UIDevice.currentDevice().orientation
        frame = viewController.view.frame
        
        if let navigationController = HMViewControllerManager.sharedInstance.navigationController {
            doneCellAnimations =  false
            UIView.animateWithDuration(0.15, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
                viewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6)
                }) { (finished) -> Void in
                    self.view.alpha = 0
                    navigationController.presentViewController(self, animated:false, completion: { () -> Void in
                        if let frame = self.frame {
                            if let containerViewWidthConstraint = self.containerViewWidthConstraint {
                                if self.slideContainerView {
                                    containerViewWidthConstraint.constant = self.minContainerViewWidth
                                } else {
                                    containerViewWidthConstraint.constant = UIScreen.mainScreen().bounds.width + 20
                                }
                                self.view.layoutIfNeeded()
                            } else {
                                self.updateFrames()
                            }
                        }
                        UIView.animateWithDuration(0.35, delay:0.0, options:.CurveEaseInOut, animations: { () -> Void in
                            self.view.alpha = 1.0
                            self.doneAnimations = true
                            if self.slideContainerView {
                                if let frame = self.frame {
                                    if let containerViewWidthConstraint = self.containerViewWidthConstraint {
                                        containerViewWidthConstraint.constant = self.maxContainerViewWidth
                                        self.view.layoutIfNeeded()
                                    } else {
                                        self.updateFrames()
                                    }
                                }
                            }
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
                self.tableView.reloadData()
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
        let completion: () -> () = {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.closeMenuFromController(self)
            self.delegate?.setNewViewController(HMViewControllerManager.sharedInstance.navigationController!, fromIndexPath: indexPath)
        }
        if animateCellMenuTap {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                if let item = cell.imageView {
                    let duration = 0.5
                    let pathFrame = CGRect(x: -CGRectGetMidX(item.bounds), y: -CGRectGetMidY(item.bounds), width: item.bounds.size.width, height: item.bounds.size.height)
                    let path = UIBezierPath(roundedRect: pathFrame, cornerRadius: item.frame.size.width/2.0)
                    let shapePosition = view.convertPoint(item.center, fromView: cell)
                    let circleShape = CAShapeLayer()
                    circleShape.path = path.CGPath
                    circleShape.position = shapePosition
                    circleShape.fillColor = UIColor.clearColor().CGColor
                    circleShape.opacity = 0
                    circleShape.strokeColor = view.tintColor.CGColor
                    circleShape.lineWidth = 0.2
                    view.layer.addSublayer(circleShape)
                    
                    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                    scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
                    scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(10.0, 10.0, 1))
                    let alphaAnimation = CABasicAnimation(keyPath: "opacity")
                    alphaAnimation.fromValue = 1
                    alphaAnimation.toValue = 0
                    let animation = CAAnimationGroup()
                    animation.animations = [scaleAnimation, alphaAnimation]
                    animation.duration = duration
                    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                    circleShape.addAnimation(animation, forKey: nil)
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * 0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                        completion()
                    }
                }
            }
        } else {
            completion()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if doneAnimations {
            return titles.count
        } else {
            return 0
        }
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
