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
    @NSManaged var idString: String
    @NSManaged var name: String
    @NSManaged var isHiring : Bool
    @NSManaged var eventID: String
    
    @NSManaged var website: String?
    @NSManaged var descriptionString: String?
    @NSManaged var logoUrl: String?
    
    /* OTHER: i.e. not defined in initial JSON Schema */
    @NSManaged var logoFilename: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /** Custom init 
     *
     */
    init(organizationJSON: OrganizationJSON, eventID: String, context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Organization", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Set a reference to the eventID since the server may need it */
        self.eventID = eventID
        
        self.idString = organizationJSON.idString
        self.name = organizationJSON.name
        self.isHiring = organizationJSON.isHiring
        
        if let website = organizationJSON.website {
            self.website = website
        }
        
        if let descriptionString = organizationJSON.descriptionString {
            self.descriptionString = descriptionString
        }
        
        if let logoUrl = organizationJSON.logoURL {
            self.logoUrl = logoUrl
        }
        
    }
    
    var logoFileName: String? {
        if let logoUrl = logoUrl {
            return logoUrl.lastPathComponent
        } else {
            return nil
        }
    }
    
    var image: UIImage? {
        get {
            guard logoFilename != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(logoFilename!)
        }
        set {
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: logoFilename!)
        }
    }
    
}
