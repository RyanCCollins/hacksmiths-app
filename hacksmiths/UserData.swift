//
//  UserData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class UserData: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var bio: String?
    @NSManaged var imageURL: String?
    @NSManaged var imageFilePath: String?
    
    // Standard required init for the entity
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init for loading our data.
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        // Set our managed data from the passed in dictionary.
        if let firstName = dictionary[HacksmithsAPIClient.Keys.FirstName] as? String, lastName = dictionary[HacksmithsAPIClient.Keys.LastName], personBio = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio] as? String, image = dictionary["photo"] as? String {
            name = "\(firstName) \(lastName)"
            bio = personBio
            imageURL = image
            imageFilePath = imageURL?.lastPathComponent
        }
    }
}
