//
//  DropOutSegueDynamic.swift
//  Class Roster
//
//  Created by Cameron Klein on 9/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit


@objc(DropOutSegueDynamic)

class DropOutSegueDynamic: UIStoryboardSegue, UICollisionBehaviorDelegate {
    
    var source : DetailViewController!
    var destination : ViewController!
    var duplicatedSourceView : UIView!
    var overlayView : UIView!
    var screenshot : UIView!
    var screenshot2 : UIView!
    
    var appdel : AppDelegate!
    
    var animator : UIDynamicAnimator?
    var gravity : UIGravityBehavior?
    var collision : UICollisionBehavior?
    var itemBehavior : UIDynamicItemBehavior?
    
    
    override func perform () {
        
        destination = self.sourceViewController as ViewController
        source = self.destinationViewController as DetailViewController
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        let center = source.view.center
        appdel = UIApplication.sharedApplication().delegate as AppDelegate
        
        //
        // Add overlay to source view
        //
        
        let overlayFrame : CGRect = appdel.window!.frame
        overlayView = UIView(frame: appdel.window!.frame)
        overlayView.alpha = 0.0
        overlayView.backgroundColor = UIColor.blackColor()
        destination.view.addSubview(overlayView)
        
        
        //Add destination view
        
        appdel.window!.addSubview(destination.view)
        
        //
        // Hide labels and such on destination
        //
        
        self.destination.nameField.alpha = 0.0
        self.destination.studentLabel.alpha = 0.0
        self.destination.gitHubUserNameField.alpha = 0.0
        self.destination.cameraButton.alpha = 0.0
        self.destination.deleteButton.alpha = 0.0
        self.destination.gitHubLogo.alpha = 0.0
        
        self.destination.nameField.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
        self.destination.studentLabel.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
        self.destination.gitHubUserNameField.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
        self.destination.cameraButton.addNaturalOnTopEffect(maximumRelativeValue: 50.0)
        self.destination.deleteButton.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
        self.destination.gitHubLogo.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
        self.destination.personImage.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
        
        self.destination.nameField.textColor = UIColor.whiteColor()
        self.destination.studentLabel.textColor = UIColor.whiteColor()
        self.destination.gitHubUserNameField.textColor = UIColor.whiteColor()
        self.destination.studentLabel.textColor = UIColor.whiteColor()
        
        //Take Screenshot
        
        screenshot2 = destination.view.snapshotViewAfterScreenUpdates(true)
        
        
        
        self.destination.personImage.alpha = 0.0
        
        
        
        destination.view.addSubview(screenshot2)
        screenshot2.center = CGPoint(x: center.x, y: center.y - screenHeight)
        
        var items = [screenshot2]
        
        animator = UIDynamicAnimator(referenceView: destination.view)
        collision = UICollisionBehavior(items: items)
        itemBehavior = UIDynamicItemBehavior(items: items)
        gravity = UIGravityBehavior(items: items)
        
        gravity!.magnitude = 4.0
        
        itemBehavior?.elasticity = 0.4
        
        animator!.addBehavior(gravity)
        animator?.addBehavior(collision)
        animator?.addBehavior(itemBehavior)
        
        collision!.translatesReferenceBoundsIntoBoundary = false
        collision?.addBoundaryWithIdentifier("barrier", fromPoint: CGPoint(x: 0.0, y: screenHeight), toPoint: CGPoint(x: screenWidth, y: screenHeight))
        
        collision?.collisionDelegate = self
        
        UIView.animateWithDuration(0.4,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.duplicatedSourceView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6)
                self.overlayView.alpha = 0.85
                
            },
            completion: { (Bool) -> Void in
                
                
                self.screenshot = self.source.view.snapshotViewAfterScreenUpdates(true)
                self.destination.view.addSubview(self.screenshot)
                self.destination.view.sendSubviewToBack(self.screenshot)
                
                self.screenshot.addNaturalBelowEffect(maximumRelativeValue: 20.0)
                
                self.source.navigationController?.pushViewController(self.destination, animated: false)
                self.destination.navigationController?.setNavigationBarHidden(false, animated: true)
                
                self.destination.view.sendSubviewToBack(self.screenshot2)
                
                let subs = self.destination.view.subviews as NSArray
                
                self.destination.view.exchangeSubviewAtIndex(subs.indexOfObject(self.screenshot), withSubviewAtIndex: subs.indexOfObject(self.screenshot2))
                
                UIView.animateWithDuration(0.75,
                    delay: 1.0,
                    options: nil,
                    animations: { () -> Void in
                        
                        self.destination.view.hidden = false
                        self.destination.nameField.alpha = 1.0
                        self.destination.studentLabel.alpha = 1.0
                        self.destination.gitHubUserNameField.alpha = 1.0
                        self.destination.studentLabel.alpha = 1.0
                        self.destination.cameraButton.alpha = 0.6
                        self.destination.deleteButton.alpha = 1.0
                        self.destination.gitHubLogo.alpha = 1.0
                        self.destination.personImage.alpha = 1.0
                        
                    },
                    completion: { (Bool) -> Void in
                        
                        self.screenshot2.removeFromSuperview()
                        self.overlayView.removeFromSuperview()
                        self.duplicatedSourceView.removeFromSuperview()
                        self.source.tableView.hidden = false
                })
                
                
                
                
        })
        
        
        
    }
    
    
    
}