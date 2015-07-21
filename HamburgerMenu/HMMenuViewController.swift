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
    func menuViewController (menuViewController:HMMenuViewController, didSelectItemAtIndex index:Int)
    optional func didShowMenuViewController (menuViewController:HMMenuViewController,  inViewController viewController:UIViewController)
    optional func didCloseMenuViewController (menuViewController:HMMenuViewController)
}

class HMMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonOriginYConstraint: NSLayoutConstraint!
    @IBOutlet var blurEffectView: UIVisualEffectView!
    
    var delegate: HMMenuViewControllerDelegate?
    var cellMenuAnimation:HMCellMenuAnimation = .SlideInAnimation
    var slideContainerView = true
    var animateCellMenuTap = true
    var viewcontrollerScaleTransformation = true
    var maxContainerViewWidth:CGFloat = 200
    var scaleTransformation:CGFloat = 0.6
    
    private let images:NSArray
    private let titles:NSArray
    private let closeImageButton:UIImage
    private let minContainerViewWidth:CGFloat = 10
    private let heightForRow = 70
    
    private var doneAnimations = false
    private var doneCellAnimations = false
    private var currentController:UIViewController?
    private var originalCloseButtonFrame:CGRect?
    private var originalTableViewFrame:CGRect?
    private var originalbuttonOriginY:CGFloat?
    private var offsetY:CGFloat?
    
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
        closeButton.setImage(closeImageButton.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
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
    
    // MARK: - Touch Methods
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        closeMenuFromController(self)
    }
    
    // MARK: - Rotation Methods
    
    @objc private func didRotate (notification: NSNotification ) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.viewcontrollerWithScaleTransformation(self.scaleTransformation)
        }
        
        updateFrames()
        
        tableView.setContentOffset(CGPointMake(0, 0), animated: false)
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
        //updating closeButton and tableView frames when using Storyboard (buttonOriginYConstraint not nil)
        if buttonOriginYConstraint != nil {
            originalbuttonOriginY = 26
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
                originalbuttonOriginY = 0
            }
            buttonOriginYConstraint.constant = originalbuttonOriginY!
            view.layoutIfNeeded()
        }
        
        if let containerViewWidthConstraint = self.containerViewWidthConstraint {
            //updating containerView frame when using Storyboard (containerViewWidthConstraint not nil)
            if slideContainerView {
                containerViewWidthConstraint.constant = doneAnimations ? maxContainerViewWidth : minContainerViewWidth
            } else {
                containerViewWidthConstraint.constant = UIScreen.mainScreen().bounds.width + 20
            }
            view.layoutIfNeeded()
        } else {
            var closeButtonOriginY:CGFloat = 26
            var tableViewFrameY:CGFloat = 55
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
                closeButtonOriginY = 0
                tableViewFrameY = 30
            }
            
            //updating closeButton frame
            closeButton.frame = CGRectMake(UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 13 : 17, closeButtonOriginY, 30, 30)
            originalCloseButtonFrame = closeButton.frame
            
            //updating containerView frame
            if slideContainerView {
                containerView.frame = CGRectMake(0, 0, doneAnimations ? maxContainerViewWidth : minContainerViewWidth, UIScreen.mainScreen().bounds.size.height)
            } else {
                containerView.frame = UIScreen.mainScreen().bounds
            }
            
            //updating blurEffectView frame
            blurEffectView.frame = UIScreen.mainScreen().bounds
            
            //updating tableView frame
            tableView.frame =  CGRectMake(0, tableViewFrameY, containerView.frame.width, containerView.frame.height)
            originalTableViewFrame = tableView.frame
        }
    }

    // MARK: - Show & Close menu

    func showMenuFromController (viewController: UIViewController) {
        if doneAnimations {
            return
        }
        
        currentController = viewController
        
        if let navigationController = HMViewControllerManager.sharedInstance.navigationController {
            doneCellAnimations =  false
            UIView.animateWithDuration(0.15, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:UIViewAnimationOptions(0), animations: { () -> Void in
                self.viewcontrollerWithScaleTransformation(self.scaleTransformation)
                }) { (finished) -> Void in
                    self.view.alpha = 0
                    navigationController.presentViewController(self, animated:false, completion: { () -> Void in
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
        } else {
            fatalError("HMViewControllerManager.sharedInstance.navigationController has not been set")
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
                HMViewControllerManager.sharedInstance.navigationController?.dismissViewControllerAnimated(false, completion: { () -> Void in
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
            self.delegate?.menuViewController(self, didSelectItemAtIndex: indexPath.row)
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
        if buttonOriginYConstraint == nil {
            var temp = tableView.frame
            temp.origin.y += offsetY! - scrollView.contentOffset.y
            if temp.origin.y < 0 {
                temp.origin.y = 0
            } else if temp.origin.y > originalTableViewFrame?.origin.y {
                temp = originalTableViewFrame!
            }
            tableView.frame = temp
            
            temp = closeButton.frame
            temp.origin.y += offsetY! - scrollView.contentOffset.y
            if temp.origin.y + temp.size.width < 0 {
                temp.origin.y = -1.0 * (originalCloseButtonFrame?.width as CGFloat!)
            } else if temp.origin.y > originalCloseButtonFrame?.origin.y {
                temp = originalCloseButtonFrame!
            }
            closeButton.frame = temp
        } else {
            buttonOriginYConstraint.constant += offsetY! - scrollView.contentOffset.y
            if buttonOriginYConstraint.constant + closeButton.frame.size.width < 0 {
                buttonOriginYConstraint.constant = -1.0 * closeButton.frame.size.width
            } else if buttonOriginYConstraint.constant > originalbuttonOriginY {
                buttonOriginYConstraint.constant = originalbuttonOriginY!
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
