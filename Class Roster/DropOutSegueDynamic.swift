//
//  DropOutSegueDynamic.swift
//  Class Roster
//
//  Created by Cameron Klein on 9/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit


@objc(DropOutSegueDynamic)

class DropOutSegueDynamic: UIStoryboardSegue {
    
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
        
        destination = self.destinationViewController as ViewController
        source = self.sourceViewController as DetailViewController
        
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
        
        UIView.animateWithDuration(0.0, animations: { () -> Void in
            self.destination.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6)
            self.overlayView.alpha = 0.85
        })
    
        // Add destination view
        
        
        let oldBack = source.view.subviews[0] as UIView
        oldBack.removeFromSuperview()
        source.view.addSubview(destination.view)
        source.view.sendSubviewToBack(destination.view)
        
        var items = [self.source.personImage]
        
        //
        // Gravity Stuff
        //
        
        animator = UIDynamicAnimator(referenceView: source.view)
        collision = UICollisionBehavior(items: items)
        itemBehavior = UIDynamicItemBehavior(items: items)
        gravity = UIGravityBehavior(items: items)
        
        gravity!.magnitude = 4.0
        
        itemBehavior?.elasticity = 0.4
        
        animator!.addBehavior(gravity)
        animator?.addBehavior(collision)
        animator?.addBehavior(itemBehavior)
        
        collision!.translatesReferenceBoundsIntoBoundary = false
        
        
        
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
            
                self.source.nameField.alpha = 0.0
                self.source.studentLabel.alpha = 0.0
                self.source.gitHubUserNameField.alpha = 0.0
                self.source.cameraButton.alpha = 0.0
                self.source.deleteButton.alpha = 0.0
                self.source.gitHubLogo.alpha = 0.0
                
            },
            completion: { (Bool) -> Void in
                

                
                
                UIView.animateWithDuration(0.5,
                    delay: 0.0,
                    options: nil,
                    animations: { () -> Void in
                        
                        self.destination.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                        self.overlayView.alpha = 0.00
                        
                        
                    },
                    completion: { (Bool) -> Void in
                        
                        self.appdel.window!.addSubview(self.destination.view)
                        
                        self.overlayView.removeFromSuperview()
                        self.source.presentViewController(self.destination, animated: false, completion: nil)
                        self.source.view.removeFromSuperview()
                        
                        
                })

                
        })
        
        
        
    }
    
    
    
}