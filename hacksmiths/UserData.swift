//
//  UserData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss
import CoreData

@objc(UserData)
class UserData: NSManagedObject {
    // Managed properties for one single user
    @NSManaged var name: String
    @NSManaged var email: String
    @NSManaged var website: String?
    @NSManaged var isPublic: Bool
    
    @NSManaged var bio: String?
    @NSManaged var mobileNotifications: Bool
    
    /* Availability */
    @NSManaged var isAvailableForEvents: Bool
    @NSManaged var availabilityExplanation: String?
    
    /* Mentoring */
    @NSManaged var isAvailableAsAMentor: Bool
    @NSManaged var needsAMentor: Bool
    @NSManaged var hasExperience: String?
    @NSManaged var wantsExperience: String?
    
    @NSManaged var avatarURL: String?
    
    
    /* Not yet mapped to JSON */
    @NSManaged var isTopContributor: Bool
    @NSManaged var dateUpdated: NSDate
    
    // Standard required init for the entity
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* - Standard messy initialization for core data.  Man, why is Core Data such a pain?
     *   This might be my last time using Core Data.
     * - parameters - UserJSONObject, the high level JSON from the User, serialized and deserialized from JSON from API
     */
    init(json: UserJSONObject, context: NSManagedObjectContext) {
        guard let name = json.user.name?.fullname else {
            return
        }
        self.name = name
        self.email = json.user.email
        if let website = json.user.website {
            self.website = website
        }
        self.isPublic = json.user.isPublic
        if let bio = json.user.bio {
            self.bio = bio.md
        }
        if let mobile = json.user.notifications?.mobile {
            self.mobileNotifications = mobile
        }
        if let isAvailableForEvents = json.user.availability?.isAvailableForEvents {
            self.isAvailableForEvents = isAvailableForEvents
        }
        if let availabilityExplanation = json.user.availability?.descriptionString {
            self.availabilityExplanation = availabilityExplanation
        }
        if let isAvailableAsAMentor = json.user.mentoring?.available {
            self.isAvailableAsAMentor = isAvailableAsAMentor
        }
        if let needsAMentor = json.user.mentoring?.needsAMentor {
            self.needsAMentor = needsAMentor
        }
        if let hasExperience = json.user.mentoring?.experience {
            self.hasExperience = hasExperience
        }
        if let wantsExperience = json.user.mentoring?.want {
            self.wantsExperience = wantsExperience
        }
        if let photo = json.user.photo {
            avatarURL = photo
        }
        if let dateUpdated = json.user.dateUpdated {
            if let date = dateUpdated.parseAsDate() {
                self.dateUpdated = date
            }
        }
    }
    
    dynamic var avatarFilePath: String? {
        if let avatarURL = avatarURL {
            return avatarURL.lastPathComponent
        } else {
            return nil
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


