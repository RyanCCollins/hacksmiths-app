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
        if let firstName = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.first] as? String, lastName = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.last], personBio = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio] as? [String : AnyObject] {
            name = "\(firstName) \(lastName)"
            
            // Ensure that the bio is in string (md) format.  May need to somehow parse out the markdown.
            bio = personBio[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bioMD] as? String
            
            if let image = dictionary["photo"] as? [String : AnyObject] {
                if let url = image["url"] as? String {
                    avatarURL = url
                    avatarFilePath = avatarURL?.lastPathComponent
                }
                
            }
            
            if let websiteURL = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.website] as? String {
                website = websiteURL
            }
            
            if let emailAddress = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.email] as? String {
                email = emailAddress
            }
            
            isPublic = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isPublic] as! Bool
            
            
            totalHatTips = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.totalHatTips] as! NSNumber
            
            isTopContributor = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.isTopContributor] as! Bool
            
            let availabilityDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.section] as! [String : AnyObject]
            
            isAvailableForEvents = availabilityDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.availability.isAvailableForEvents] as! Bool
            let notificationDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.notifications] as! [String : AnyObject]
            
            if let mobileNotifs = notificationDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.mobile] as? Bool {
                
                mobileNotifications = mobileNotifs
                
            }
            
            rank = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.rank] as! NSNumber
            
           // if let mentoringDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.dictionaryKey] as? [String : AnyObject]{
             //
               // isAvailableAsAMentor = mentoringDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.available]
                
               // needsAMentor = mentoringDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.needsAMentor]
           // }
            
        }
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
