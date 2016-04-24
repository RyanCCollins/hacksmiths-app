//
//  Sponsor.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

@objc(Organization)

class Organization: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var logoUrl: String?
    @NSManaged var logoFilename: String?
    @NSManaged var website: String?
    @NSManaged var isHiring : Bool
    @NSManaged var about : String?
    @NSManaged var events: [Event]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Organization", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        id = dictionary[HacksmithsAPIClient.JSONResponseKeys.Organization.id] as! String
        name = dictionary[HacksmithsAPIClient.JSONResponseKeys.Organization.name] as! String
        website = dictionary[HacksmithsAPIClient.JSONResponseKeys.Organization.website] as! String
        about = dictionary[HacksmithsAPIClient.JSONResponseKeys.Organization.md] as! String
        logoUrl = dictionary[HacksmithsAPIClient.JSONResponseKeys.Organization.logoUrl] as! String
        logoFilename = logoUrl?.lastPathComponent
        isHiring = dictionary[HacksmithsAPIClient.JSONResponseKeys.Organization.isHiring] as! Bool
        
    }
    
}
