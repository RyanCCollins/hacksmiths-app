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
    // Managed properties for one single user
    @NSManaged var name: String?
    @NSManaged var bio: String?
    @NSManaged var avatarURL: String?
    @NSManaged var avatarFilePath: String?
    @NSManaged var website: String?
    @NSManaged var email: String?
    @NSManaged var isPublic: Bool
    @NSManaged var isTopContributor: Bool
    @NSManaged var rank: NSNumber
    @NSManaged var isAvailableForEvents: Bool
    @NSManaged var mobileNotifications: Bool
    @NSManaged var isAvailableAsAMentor: Bool
    @NSManaged var needsAMentor: Bool
    @NSManaged var totalHatTips: NSNumber
    @NSManaged var dateUpdated: NSDate
    
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
        // Name is a dictionary with first and last name
        // Bio is a dictionary object with HTML and MD (we are only concerned with MD
        
        name = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.name] as? String
        bio = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio] as? String
        

        
        // The image also comes as a dictionary object, so parse that out and get the URL
        if let image = dictionary["photo"] as? [String : AnyObject] {
            if let url = image["url"] as? String {
                avatarURL = url
                avatarFilePath = avatarURL?.lastPathComponent
            }
            
        }
        
        website = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.website] as? String
        
        if let emailAddress = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.email] as? String {
            email = emailAddress
        }
        
        isPublic = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isPublic] as! Bool
        totalHatTips = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.totalHatTips] as! NSNumber
        isTopContributor = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.isTopContributor] as! Bool
        
        // Availability comes as a dictionary object with dates available as well as a bool indicating if they are available.
        let availabilityDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.dictKey] as! [String : AnyObject]
        
        // Drill down to the isAvailable bool within the availability dict.
        isAvailableForEvents = availabilityDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.availability.isAvailableForEvents] as! Bool
        
        // Notifications is a dictionary object.  Parse it to get to the value for mobile notifs.
        let notificationDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.notifications] as! [String : AnyObject]
        
        if let mobileNotifs = notificationDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.mobile] as? Bool {
            
            mobileNotifications = mobileNotifs
            
        }
        
        rank = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.rank] as! NSNumber
        
        // Values are initialized as false, so will not be null.
        isAvailableAsAMentor = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.available] as! Bool
        needsAMentor = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.needsAMentor] as! Bool

        
        if let updatedAt = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.updatedAt] as? String {
            if let dateUpdatedAt = dateFromString(updatedAt) {
                dateUpdated = dateUpdatedAt
            }
        }
            

    }
    
    func dateFromString(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let date = dateFormatter.dateFromString(dateString)
        if let date = date {
            return date
        }
        return nil
    }
    
    func fetchImages(completionHandler: CompletionHandler) {
        guard avatarURL != nil else {
            return
        }
        
        HacksmithsAPIClient.sharedInstance().taskForGETImageFromURL(avatarURL!, completionHandler: {image, error in
            
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                
                self.image = image
                
            }
            
        })
    }
    
    var image: UIImage? {
        get {
            guard avatarFilePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(avatarFilePath!)
        }
        set {
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: avatarFilePath!)
        }
    }
    
}
