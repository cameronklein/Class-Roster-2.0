//
//  ViewController.swift
//  Person Array iOS
//
//  Created by Cameron Klein on 8/7/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var personArray = [[Person]]()
    
    //MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializePersonArray()
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.initializePersonArray()
        
        tableView.reloadData()
        
        saveData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier! == "Detail" {
            let index = tableView.indexPathForSelectedRow()
            let selectedPerson = personArray[index.section][index.row]
            let destination = segue.destinationViewController as DetailViewController
            destination.thisPerson = selectedPerson
        }
    }
    
    //MARK: Unwind Methods
    
    @IBAction func unwindFromCreateNewPerson(segue: UIStoryboardSegue){
        
        let sourceViewController: AddPersonViewController = segue.sourceViewController as AddPersonViewController
        
        let firstName   =   sourceViewController.firstName
        let lastName    =   sourceViewController.lastName
        let position    =   sourceViewController.position as String
        
        var context  : NSManagedObjectContext = getContext()
        
        var newPerson = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context) as Person
        
        newPerson.firstName     = firstName!
        newPerson.lastName      = lastName!
        newPerson.position      = position
        
        saveData()
        initializePersonArray()
        
        println(newPerson.fullName() + " added.")
        
    }
    
    @IBAction func unwindFromCancelButton(segue: UIStoryboardSegue){/*Do nothing*/}
    
    
    @IBAction func unwindFromDeletePerson(segue: UIStoryboardSegue){
        
        let sourceViewController: DetailViewController = segue.sourceViewController as DetailViewController
        let thisPerson : Person = sourceViewController.thisPerson
        var context  : NSManagedObjectContext = getContext()
        context.deleteObject(thisPerson)
        println(thisPerson.fullName() + " deleted.")
    }
    
    // MARK: UITableView Data Source / Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        
        return personArray.count
        
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return personArray[section].count
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        var thisPerson = self.personArray[indexPath.section][indexPath.row] as Person
        cell.textLabel.text = thisPerson.fullName()
        
        var image : UIImage? = UIImage(data: thisPerson.image)
        
        if image == nil{
            image = UIImage(named: "unknownSilhouette")
        }
        
        cell.imageView.image = getSmallImagefromBigImage(image!)
        
        
        cell.imageView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.borderColor = UIColor.blackColor().CGColor
        cell.imageView.layer.borderWidth = 1
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height / 2.0
        
        return cell
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        switch section {
        case 0: return "Students"
        case 1: return "Teachers"
        default: return " "
            
        }
    }
    
    func tableView(tableView: UITableView!, willDisplayHeaderView view: UIView!, forSection section: Int) {
        
    }
    
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    //MARK: CoreData
    
    func getContext() -> NSManagedObjectContext {
        var appDel : AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
        var context  : NSManagedObjectContext =  appDel.managedObjectContext!
        return context
    }
    
    func saveData(){
        
        if getContext().save(nil){
            println("Data Successfully Saved")
        }
    }
    
    
    //MARK: Array Initialization
    
    func initializePersonArray(){
        
        var context  : NSManagedObjectContext = getContext()
        
        var request = NSFetchRequest(entityName: "People")
        request.returnsObjectsAsFaults = false
        
        personArray.removeAll(keepCapacity: true)
        
        request.predicate = NSPredicate(format: "position == %@", "Student")
        var studentArray = context.executeFetchRequest(request, error: nil) as [Person]
        studentArray.sort { $0.firstName < $1.firstName }
        
        if studentArray.isEmpty == false{
            personArray.append(studentArray)
        }
        
        request.predicate = NSPredicate(format: "position == %@", "Teacher")
        var teacherArray = context.executeFetchRequest(request, error: nil) as [Person]
        teacherArray.sort { $0.firstName < $1.firstName }
        
        if teacherArray.isEmpty == false{
            personArray.append(teacherArray)
        }
        
        if personArray.isEmpty{
            self.initializeArrayFromBackup()
        }
        
    }
    
    func initializeArrayFromBackup(){
        
        let path = NSBundle.mainBundle().pathForResource("Roster", ofType:"plist")
        let array = NSArray(contentsOfFile:path!)
        
        var context  : NSManagedObjectContext =  getContext()
        
        for person in array{
            
            var thisPerson: AnyObject! = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context)
            
            thisPerson.setValue(person["firstName"] , forKey: "firstName")
            thisPerson.setValue(person["lastName"]  , forKey: "lastName")
            thisPerson.setValue(person["position"]  , forKey: "position")
            thisPerson.setValue(nil                 , forKey: "image")
            
        }
        println("Persons inserted from backup plist.")
        
        
        
        saveData()
    }
    
    //MARK: Other
    
    func getSmallImagefromBigImage(image: UIImage) -> UIImage{
        
        UIGraphicsBeginImageContext(CGSizeMake(40.0, 40.0))
        
        image.drawInRect(CGRectMake(0.0, 0.0, 40.0, 40.0))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
}

