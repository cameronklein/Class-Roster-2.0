//
//  DropInSegue.swift
//  Class Roster
//
//  Created by Cameron Klein on 9/11/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

@objc(DropInSegue)

class DropInSegue: UIStoryboardSegue {
    
    var source : ViewController!
    var destination : DetailViewController!
    var duplicatedSourceView : UIView!
    var overlayView : UIView!
    var screenshot : UIView!
    var appdel : AppDelegate!
    
    
    override func perform () {
        source = self.sourceViewController as ViewController
        destination = self.destinationViewController as DetailViewController
        duplicatedSourceView = source.view.snapshotViewAfterScreenUpdates(true)
        
//        destination.view.addSubview(duplicatedSourceView)
//        destination.view.sendSubviewToBack(duplicatedSourceView)
        let screenHeight = UIScreen.mainScreen().bounds.height
        let center = source.view.center
        appdel = UIApplication.sharedApplication().delegate as AppDelegate
        appdel.window!.addSubview(destination.view)
        
        self.source.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        source.view.addSubview(duplicatedSourceView)
        source.tableView.hidden = true
        
        destination.view.center = CGPoint(x: center.x, y: center.y - screenHeight)
            
        let overlayFrame : CGRect = appdel.window!.frame
        
        overlayView = UIView(frame: appdel.window!.frame)
        overlayView.alpha = 0.0
        overlayView.backgroundColor = UIColor.blackColor()
        
        source.view.addSubview(overlayView)
        
        UIView.animateWithDuration(0.5,
            delay: 0.0,
//            usingSpringWithDamping: 0.4,
//            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                self.duplicatedSourceView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)
                self.overlayView.alpha = 0.85
                
            },
            completion: { (Bool) -> Void in
                
                
                self.screenshot = self.source.view.snapshotViewAfterScreenUpdates(true)
                
                
//                UIGraphicsBeginImageContext(self.appdel.window!.frame.size);
//                self.appdel.window!.layer.renderInContext(UIGraphicsGetCurrentContext())
//                
//                self.screenshot = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
                
                self.destination.nameField.alpha = 0.0
                self.destination.studentLabel.alpha = 0.0
                self.destination.gitHubUserNameField.alpha = 0.0
                self.destination.studentLabel.alpha = 0.0
                self.destination.cameraButton.alpha = 0.0
                self.destination.deleteButton.alpha = 0.0
                self.destination.gitHubLogo.alpha = 0.0
                
                self.destination.nameField.textColor = UIColor.whiteColor()
                self.destination.studentLabel.textColor = UIColor.whiteColor()
                self.destination.gitHubUserNameField.textColor = UIColor.whiteColor()
                self.destination.studentLabel.textColor = UIColor.whiteColor()
                self.destination.cameraButton.alpha = 0.0
                self.destination.deleteButton.alpha = 0.0
                self.destination.gitHubLogo.alpha = 0.0
                
                
                
                UIView.animateWithDuration(0.75,
                    delay: 0.0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 6.0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: { () -> Void in
                        
                        
                        self.destination.view.center = center
                        
                        
                    },
                    completion: { (Bool) -> Void in
                        
                        self.source.navigationController?.pushViewController(self.destination, animated: false)
                        self.destination.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.destination.view.addSubview(self.screenshot)
                        self.destination.view.sendSubviewToBack(self.screenshot)
                        
                        
                        UIView.animateWithDuration(0.6,
                            delay: 0.2,
                            options: UIViewAnimationOptions.AllowUserInteraction,
                            animations: { () -> Void in
                                self.destination.nameField.alpha = 1.0
                                self.destination.studentLabel.alpha = 1.0
                                self.destination.gitHubUserNameField.alpha = 1.0
                                self.destination.studentLabel.alpha = 1.0
                                self.destination.cameraButton.alpha = 0.6
                                self.destination.deleteButton.alpha = 1.0
                                self.destination.gitHubLogo.alpha = 1.0
                            },
                            completion: nil)
                        
                        
                        
                        
                        
                        self.overlayView.removeFromSuperview()
                        self.duplicatedSourceView.removeFromSuperview()
                        self.source.tableView.hidden = false
        })

        
        
                
        })
        
        
        
    }
    
    
    
}