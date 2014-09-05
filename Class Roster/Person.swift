//
//  Person.swift
//  Person Array iOS
//
//  Created by Cameron Klein on 8/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import CoreData

@objc(Person)
class Person: NSManagedObject {
    
    @NSManaged var firstName            :   String
    @NSManaged var lastName             :   String
    @NSManaged var position             :   String?
    @NSManaged var gitHubUserName       :   String?
    
    @NSManaged var image                :   NSData?
    
    //MARK: Initializers
    
    //Initialize with seperate first and last names.
    convenience init(firstName: String, lastName : String){
        self.init()
        self.firstName  =   firstName
        self.lastName   =   lastName
        
    }
    
    //Initialize with full name as one string.
    convenience init(fullName: String){
        
        let nameArray = fullName.componentsSeparatedByString(" ")
        
        //Handle long names
        if nameArray.count == 2{
            self.init(firstName: nameArray[0], lastName: nameArray.last as String!)
        } else{
            var first = nameArray[0]
            for i in 1..<(nameArray.count-1) {
                first = first + " " + nameArray[i]
                }
            self.init(firstName: first, lastName: nameArray.last as String!)
        }
    }
    
    convenience init(firstName: String, lastName: String, position: String){
        self.init()
        self.firstName  =   firstName
        self.lastName   =   lastName
        self.position   =   position
    }
    
    func parseNameFromString(fullName: String) -> (String, String){
        
        let nameArray = fullName.componentsSeparatedByString(" ")
        
        if nameArray.count == 2{
            return (nameArray[0], nameArray[1])
        } else{
            var first = nameArray[0]
            for i in 1..<(nameArray.count-1) {
                first = first + " " + nameArray[i]
            }
            return (first, nameArray.last as String!)
        }
        
    }
    
    //MARK: Other
    
    func fullName() -> String {
        return self.firstName + " " + self.lastName
    }
    
    
    func setFullName(fullName: String){
        let (firstName, lastName) = parseNameFromString(fullName)
        
        self.firstName = firstName
        self.lastName = lastName
    }

    
}