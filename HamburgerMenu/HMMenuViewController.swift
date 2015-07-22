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
    func menuViewController (menuViewController:HMMenuViewController, didSelectItemAtIndexPath indexPath:NSIndexPath)
    optional func didShowMenuViewController (menuViewController:HMMenuViewController,  inViewController viewController:UIViewController)
    optional func didCloseMenuViewController (menuViewController:HMMenuViewController)
}

class HMMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var containerView: UIView! // contains tableView and closeButton, added as a subView of self.view
    @IBOutlet var blurEffectView: UIVisualEffectView! //used to add background blur effect
    @IBOutlet var containerViewWidthConstraint: NSLayoutConstraint! // used to animate containerView sliding
    @IBOutlet var closeButtonTopSpaceConstraint: NSLayoutConstraint! // used to animate hiding closeButton when scrolling tableView up
    
    var delegate: HMMenuViewControllerDelegate?
    var cellMenuAnimation:HMCellMenuAnimation = .SlideInAnimation
    var slideContainerView = true
    var animateCellMenuTap = true
    var viewcontrollerScaleTransformation = true
    var closeMenuAfterRotation = false
    var maxContainerViewWidth:CGFloat = 200
    var scaleTransformation:CGFloat = 0.6
    
    var images:NSArray!
    var titles:NSArray!
    var closeImageButton:UIImage!
    private let minContainerViewWidth:CGFloat = 10
    private let heightForRow = 70
    
    private weak var currentController:UIViewController?
    private var doneAnimations = false
    private var doneCellAnimations = false
    private var closeButtonTopSpace:CGFloat = 26
    private var offsetY:CGFloat?
    
    // MARK: - Computed properties
    
    private var navController:UIViewController {
        var controller = UIApplication.sharedApplication().keyWindow?.rootViewController
        while controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }
        if controller == nil {
            fatalError("UIApplication.sharedApplication().keyWindow?.rootViewController (navigationController) has not been set")
        }
        return controller!
    }
    
    // MARK: - Initializers
    
    init (images:NSArray, titles:NSArray, closeImageButton:UIImage) {
        self.images = images
        self.titles = titles
        self.closeImageButton = closeImageButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if images == nil || titles == nil || closeImageButton == nil {
            fatalError("\(self) - Some properties (images, titles, closeImageButton) have not been set")
        }
        
        // view setup
        view.backgroundColor = UIColor.clearColor()
        view.tintColor = UIColor.whiteColor()
        
        // ViewController setup
        modalPresentationStyle = .OverCurrentContext
        
        // blurEffectView setup
        if blurEffectView == nil {
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
            blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            blurEffectView.frame = view.bounds
            blurEffectView.alpha = 0.7
            view.addSubview(blurEffectView)
        }
        
        // closeButton setup
        if closeButton == nil {
            closeButton = UIButton.buttonWithType(.Custom) as? UIButton
            closeButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.setImage(closeImageButton.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        closeButton.setTitle("", forState: .Normal)
        closeButton.addTarget(self, action: Selector("closeMenuFromController:"), forControlEvents:.TouchUpInside)
        
        //tableview setup
        if tableView == nil {
            tableView = UITableView()
            tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
            containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
            containerView.addSubview(tableView)
            containerView.addSubview(closeButton)
            view.addSubview(containerView)
        }
        containerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        // setting constraints programmatically
        if containerView.constraints().count == 0 && closeButton.constraints().count == 0 && tableView.constraints().count == 0 && blurEffectView.constraints().count == 0 {
            let views = ["containerView":containerView,"closeButton":closeButton,"tableView":tableView,"blurEffectView":blurEffectView]
            let metrics = ["closeButtonSize":30.0, "closeButtonLeadingSpace":13.0, "closeButtonTopSpace":closeButtonTopSpace, "containerViewWidth":minContainerViewWidth]
            
            // containerView constraints
            let containerViewConstraintsH:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[containerView(containerViewWidth)]", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            let containerViewConstraintsV:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[containerView]-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            
            view.addConstraints(containerViewConstraintsH as [AnyObject])
            view.addConstraints(containerViewConstraintsV as [AnyObject])
            
            // containerView constraints
            let blurEffectViewConstraintsH:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[blurEffectView]-0-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            let blurEffectViewConstraintsV:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[blurEffectView]-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            
            view.addConstraints(blurEffectViewConstraintsH as [AnyObject])
            view.addConstraints(blurEffectViewConstraintsV as [AnyObject])
            
            // closeButton and tableView constraints
            let closeButtonConstraintsH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-closeButtonLeadingSpace-[closeButton(closeButtonSize)]", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            let closeButtonAndTableViewConstraintsV:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-closeButtonTopSpace-[closeButton(closeButtonSize)]-0-[tableView]-0-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            let tableViewConstraintsH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tableView]-0-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views)
            
            containerView.addConstraints(tableViewConstraintsH)
            containerView.addConstraints(closeButtonConstraintsH)
            containerView.addConstraints(closeButtonAndTableViewConstraintsV)
            
            for constraint in containerViewConstraintsH {
                if constraint.constant == minContainerViewWidth {
                    containerViewWidthConstraint = constraint as? NSLayoutConstraint
                }
            }
            
            for constraint in closeButtonAndTableViewConstraintsV {
                if constraint.constant == closeButtonTopSpace {
                    closeButtonTopSpaceConstraint = constraint as? NSLayoutConstraint
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("didRotate:"), name:"UIDeviceOrientationDidChangeNotification" , object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Touch Methods
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        closeMenuFromController(self)
    }
    
    // MARK: - Rotation Methods
    
    @objc private func didRotate (notification: NSNotification ) {
        if closeMenuAfterRotation {
            closeMenuFromController(self)
            return
        }
        
        tableView.setContentOffset(CGPointMake(0, 0), animated: false)
        self.updateFrames()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.viewcontrollerWithScaleTransformation(self.scaleTransformation)
        }
    }
    
    @objc private func viewcontrollerWithScaleTransformation (scale: CGFloat) {
        if viewcontrollerScaleTransformation {
            currentController?.view.transform = CGAffineTransformIdentity
            currentController?.view.frame = UIScreen.mainScreen().bounds
            currentController?.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale)
        }
    }
    
    // MARK: - Update frames and constraints methods
    
    @objc private func updateFrames () {
        //updating closeButton and tableView frames
        if closeButtonTopSpaceConstraint != nil {
            closeButtonTopSpace = 26
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
                closeButtonTopSpace = 0
            }
            closeButtonTopSpaceConstraint.constant = closeButtonTopSpace
        }
        
        //updating containerView frame
        if let containerViewWidthConstraint = self.containerViewWidthConstraint {
            if slideContainerView {
                containerViewWidthConstraint.constant = doneAnimations ? maxContainerViewWidth : minContainerViewWidth
            } else {
                containerViewWidthConstraint.constant = UIScreen.mainScreen().bounds.width + 20
            }
        }
        
        view.layoutIfNeeded()
    }

    // MARK: - Show & Close menu

    func showMenuFromController (viewController: UIViewController) {
        if doneAnimations {
            return
        }
        
        currentController = viewController
        doneCellAnimations =  false
        UIView.animateWithDuration(0.15, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
            self.viewcontrollerWithScaleTransformation(self.scaleTransformation)
            }) { (finished) -> Void in
                self.view.alpha = 0
                self.navController.presentViewController(self, animated:false, completion: { () -> Void in
                    self.updateFrames()
                    UIView.animateWithDuration(0.35, delay:0.0, options:.CurveEaseInOut, animations: { () -> Void in
                        self.view.alpha = 1.0
                        self.doneAnimations = true
                        self.updateFrames()
                        self.tableView.reloadData()
                        }, completion: { (finished) -> Void in
                            self.doneCellAnimations = true
                            if self.delegate?.respondsToSelector(Selector("didShowMenu:inViewController:")) == true {
                                self.delegate?.didShowMenuViewController!(self, inViewController: viewController)
                            }
                    })
                })
        }
    }
    
    func closeMenuFromController (viewController:UIViewController) {
        if !doneAnimations {
            return
        }
        
        UIView.animateWithDuration(0.3/1.5, delay:0.0, usingSpringWithDamping:1.0, initialSpringVelocity:1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
            self.viewcontrollerWithScaleTransformation(1.0)
            }) { (finished) -> Void in
                self.doneAnimations = false
                self.tableView.reloadData()
                self.navController.dismissViewControllerAnimated(false, completion: { () -> Void in
                    if self.delegate?.respondsToSelector(Selector("didCloseMenu:")) == true {
                        self.delegate?.didCloseMenuViewController!(self)
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
        cell?.imageView?.image = makeThumbnail((images.objectAtIndex(indexPath.row) as? UIImage)!, ofSize: CGSizeMake(40, 40)).imageWithRenderingMode(.AlwaysTemplate)
        cell?.textLabel?.text = titles.objectAtIndex(indexPath.row) as? String
        return cell!
    }
    
    func makeThumbnail (image:UIImage,  ofSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let temp =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return temp
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let completion: () -> () = {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.closeMenuFromController(self)
            self.delegate?.menuViewController(self, didSelectItemAtIndexPath:indexPath)
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
            tableView.scrollEnabled = titles.count * heightForRow > Int(tableView.frame.size.height) ? true : false
            return titles.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(heightForRow)
    }
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        offsetY = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if closeButtonTopSpaceConstraint != nil {
            closeButtonTopSpaceConstraint.constant += offsetY! - scrollView.contentOffset.y
            if closeButtonTopSpaceConstraint.constant + closeButton.frame.size.width < 0 {
                closeButtonTopSpaceConstraint.constant = -1.0 * closeButton.frame.size.width
            } else if closeButtonTopSpaceConstraint.constant > closeButtonTopSpace {
                closeButtonTopSpaceConstraint.constant = closeButtonTopSpace
            }
            view.layoutIfNeeded()
        }
        offsetY = scrollView.contentOffset.y
    }
    
    // MARK: - Cell animations
    
    private func performSlideInCellAnimationsWithCell (cell:UITableViewCell, forRowIndexPath indexPath:NSIndexPath) {
        let oldFrame = cell.frame
        let newFrame = CGRectMake(-cell.frame.size.width, cell.frame.origin.y, 0, cell.frame.size.height)
        
        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.0001)
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
            cell.frame = oldFrame
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
