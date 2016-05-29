//
//  Enrollment.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

@objc(Enrollment)
class Enrollment: NSManagedObject {
    /* Managed Core Data properties for storing
     * Enrollment data (i.e. what Nanodegrees a user is enrolled in
     * 
     * NOTE: This is not being used in v1, but significant effort went into it
     * and it will be used in a later release.
     */
    @NSManaged var idString: String
    @NSManaged var title: String
    @NSManaged var descriptionString: String?
    @NSManaged var logoUrl: String?
    @NSManaged var updatedAt: String?
    @NSManaged var link: String?
    
    
    /* 
     *  Standard required init for the entity
     */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
        Core data initialization
        @param enrollmentJSON - JSON Returned from API endpoint
        @param context - standard core data context
     */
    init(enrollmentJSON: EnrollmentJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Enrollment", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.idString = enrollmentJSON.id
        self.title = enrollmentJSON.title
        if let description = enrollmentJSON.description {
            self.descriptionString = description
        }
        if let updatedAt = enrollmentJSON.updatedAt {
            self.updatedAt = updatedAt
        }
        if let link = enrollmentJSON.link {
            self.link = link
        }
        
        if let logo = enrollmentJSON.logo {
            self.logoUrl = logo
        }
    }
    
    /** 
        Computed Property for getting logo image
        @return logo: UIImage? - An image if the filepath is set, or nil if not
     */
    var logo: UIImage? {
        get {
            guard logoFilePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(logoFilePath!)
        }
        set {
            guard let filePath = self.logoFilePath else {
                return
            }
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath)
        }
    }
    

    /**
        Computed Property for updatedDate
        @return returnDate: NSDate - A date if the date is properly parsed from a string.
     */
    var updatedDate: NSDate? {
        var returnDate: NSDate? = nil
        if updatedAt != nil {
            if let date = updatedAt?.parseAsDate() {
                returnDate = date
            }
        }
        return returnDate
    }
    
    

    /**
        Computed Property for logo file path
        @return logoFilePath: String - The filepath to the logo if one exists
     */
    var logoFilePath: String? {
        return logoUrl != nil ? logoUrl!.lastPathComponent : nil
    }
}