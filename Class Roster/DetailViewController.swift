//
//  PersonVC.swift
//  Person Array iOS
//
//  Created by Cameron Klein on 8/11/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var thisPerson : Person!
    var imageDownloadQueue = NSOperationQueue()
    
    @IBOutlet weak var personImage          :   UIImageView!
    @IBOutlet weak var nameField            :   UITextField!
    @IBOutlet weak var studentLabel         :   UILabel!
    @IBOutlet weak var cameraButton         :   UIButton!
    @IBOutlet weak var gitHubUserNameField  :   UITextField!
    @IBOutlet weak var spinningWheel        :   UIActivityIndicatorView!
    
    //MARK: Lifecycle Methods
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        nameField.text              = thisPerson.fullName()
        studentLabel.text           = thisPerson.position
        gitHubUserNameField.text    = thisPerson.gitHubUserName
        personImage.image           = UIImage(data: thisPerson.image)
        
        if thisPerson.image == nil{
            personImage.image = UIImage(named: "unknownSilhouette")
        }
        
        self.nameField.delegate             = self
        self.gitHubUserNameField.delegate   = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        UIView.animateWithDuration(0.0, animations: { () -> Void in
            self.cameraButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01)
        })
        
        personImage.clipsToBounds = true
        personImage.layer.borderColor = UIColor.blackColor().CGColor
        personImage.layer.borderWidth = 2
        
        animateImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if thisPerson.image == nil && thisPerson.gitHubUserName != nil{
            updateImageFromGitHubUserName(thisPerson.gitHubUserName!)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        personImage.layer.cornerRadius = self.personImage.frame.size.width / 2;
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        let image = info["UIImagePickerControllerEditedImage"] as UIImage
        
        self.personImage.image  = image
        self.thisPerson.image = UIImagePNGRepresentation(image)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    //MARK: Keyboard Notification Methods
    
    func keyboardWillShow(){
        if gitHubUserNameField.isFirstResponder(){
            self.view.bounds.origin.y = self.view.frame.height / 3.5
        }
    }
    
    func keyboardWillHide(){
        if gitHubUserNameField.isFirstResponder(){
            self.view.bounds.origin.y = 0
        }
    }
    
    
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        println("should return")
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField!) {
        println("Did End Editing")
        
        if textField == gitHubUserNameField{
            thisPerson.gitHubUserName = textField.text
            
            var alert = UIAlertController(title: "", message: "Download image from GitHub?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.updateImageFromGitHubUserName(textField.text)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            gitHubUserNameField.resignFirstResponder()
            
        } else if textField == nameField{
            
            var nameArray = nameField.text.componentsSeparatedByString(" ")
            
            if nameArray.count < 2{
                var alert: UIAlertView = UIAlertView()
                alert.title     = "Name not updated!"
                alert.message   = "Only one name was provided. Please enter both first and last name."
                alert.addButtonWithTitle("Ok")
                alert.show()
                nameField.text = thisPerson.fullName()
            } else {
                thisPerson.setFullName(nameField.text)
            }
            nameField.resignFirstResponder()
            
        }
        
        
    }
    
    //MARK: GitHub
    
    func askForGithubUserName(){
        
        var alert = UIAlertController(title: "Enter GitHub Username", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Username"
            textField.secureTextEntry = false
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            let textField = alert.textFields[0] as UITextField
            let username = textField.text as String
            println(username)
            self.thisPerson.gitHubUserName = username
            self.updateImageFromGitHubUserName(username)
            self.gitHubUserNameField.text = username
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler: nil))
        
        self.presentViewController(alert, animated: true, nil)
        
    }
    
    
    func updateImageFromGitHubUserName(username: String){
        
        println(username)
        var url = NSURL(string: "https://api.github.com/users/" + username)
        
        personImage.alpha = 0
        spinningWheel.startAnimating()
        var statusCode: Int = 0
        
        let request = NSMutableURLRequest(URL: url)
        
        //request.setValue("token 4bed1fd2237ceb5ea250cbb0d7c15ad630a9876c", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
            println("Data Retrieved")
            
            let thisResponse = response as NSHTTPURLResponse
            statusCode = thisResponse.statusCode
            
            println("Status Code: \(statusCode)")
            
            switch statusCode{
                
            case 200:
                
                var dictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                let avatarURLString: String = dictionary["avatar_url"]! as String
                
                let avatarURL = NSURL(string: avatarURLString)
                
                let userAvatar : NSData = NSData(contentsOfURL: avatarURL)
                
                self.thisPerson.image = userAvatar
                
                let avatarImage = UIImage(data: userAvatar)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.personImage.image = avatarImage
                    self.personImage.alpha = 1.0
                    self.spinningWheel.stopAnimating()
                })
                
            case 403,404:
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                    self.personImage.image = UIImage(named: "unknownSilhouette")
                    self.personImage.alpha = 1.0
                    self.spinningWheel.stopAnimating()
                    
                    var alert = UIAlertController(title: "", message: "API Limit Reached", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
                
            default:
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                    println("Oops!")
                    
                    self.personImage.image = UIImage(named: "unknownSilhouette")
                    self.personImage.alpha = 1.0
                    self.spinningWheel.stopAnimating()
                    
                })
            }
        }
        
        task.resume()
        
    }
    
    //MARK: Other
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        nameField.resignFirstResponder()
        gitHubUserNameField.resignFirstResponder()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        
        var actionSheet = UIAlertController(title: "Choose Image Source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(picker, animated: true, completion: nil)
            }))
        }
        
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(picker, animated: true, completion: nil)
            }))
        
            actionSheet.addAction(UIAlertAction(title: "Import from GitHub", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.askForGithubUserName()
            }))
        
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                actionSheet.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(actionSheet, animated: true, completion: nil)
        
        }
    
    @IBAction func didTouchButton(sender: AnyObject) {
        cameraButton.alpha = 1.0
    }
    
    func animateImage(){

        UIView.animateWithDuration(1.0,
            delay: 1.0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
            },
            completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.8,
                    delay: 1.2,
                    options: UIViewAnimationOptions.AllowUserInteraction,
                    animations: { () -> Void in
                        self.cameraButton.alpha = 0.5
                },  completion: nil)
                
            })
    }
    
    
}

    