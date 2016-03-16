//
//  Person.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData
import UIKit

@objc(User)

class Person: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email : String?
    @NSManaged var bio: String?
    @NSManaged var isPublic: Bool
    @NSManaged var isLeader: Bool
    @NSManaged var isTopContributor: Bool
    @NSManaged var avatarURL: String?
    @NSManaged var avatarFilePath: String?
    @NSManaged var website: String?
    @NSManaged var githubUsername: String?
    @NSManaged var twitterUsername: String?
    @NSManaged var sortPriority: NSNumber?
    //@NSManaged var rank: NSNumber?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        let name = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.name] as! [String : AnyObject]
        firstName = name["first"] as! String
        lastName = name["last"] as! String
        
        id = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData._id] as! String
        
        if let userEmail = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.email] as? String {
            email = userEmail
        }
        
        //* Bio comes in markdown, although that should likely be changed.
        if let userBio = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio] as? [String : AnyObject] {
            let mdBio = userBio["md"] as! String
            bio = mdBio
        }
        
        if let photoDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.photo] as? [String : AnyObject] {
            avatarURL = photoDictionary["url"] as? String
            avatarFilePath = avatarURL?.lastPathComponent
            print(">>>Saving photo with url of \(avatarURL) with filepath of \(avatarFilePath)")
        }
        
        isLeader = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isLeader] as! Bool
        isPublic = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isPublic] as! Bool
        isTopContributor = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.isTopContributor] as! Bool
        sortPriority = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.sortPriority] as? NSNumber
        
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
    
    var githubURL: NSURL? {
        get {
            guard githubUsername != nil else {
                return nil
            }
            
            let URLString = "http://github.com/" + githubUsername!
            return NSURL(string: URLString)
        }
    }
    
    var twitterURL: NSURL? {
        get {
            guard twitterUsername != nil else {
                return nil
            }
            
            let URLString = "http://twitter.com/" + twitterUsername!
            return NSURL(string: URLString)
        }
    }
}

/* Added to help bridge the gap for finding the last path component in Swift
Reference are here: https://forums.developer.apple.com/thread/13580 */

extension String {
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
}