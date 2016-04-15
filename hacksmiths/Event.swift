//
//  Event.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

@objc(Event)

class Event: NSManagedObject {
    
    @NSManaged var eventID: String
    @NSManaged var title: String
    @NSManaged var organization : String?
    @NSManaged var descriptionString: String?
    @NSManaged var registrationStart : NSDate
    @NSManaged var registrationEnd : NSDate?
    @NSManaged var sponsors: [Organization]
    @NSManaged var startDate: NSDate?
    @NSManaged var endDate: NSDate?
    
    @NSManaged var maxRSVPS: NSNumber
    @NSManaged var totalRSVPS: NSNumber
    @NSManaged var spotsAvailable: Bool
    @NSManaged var spotsRemaining: NSNumber
    
    @NSManaged var marketingInfo: String
    
    @NSManaged var featureImageURL: String?
    @NSManaged var featureImageFilePath: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        eventID = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.id] as! String
        title = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.title] as! String
        descriptionString = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.description] as! String
        let dateStringStart = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.starts] as! String
        let dateStringEnd = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.ends] as! String
        if let start = dateFromString(dateStringStart), end = dateFromString(dateStringEnd) {
            startDate = start
            endDate = end
        }
        
        if let spots = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.spotsRemaining] as? Int {
            spotsRemaining = spots
            if spots > 0 {
                spotsAvailable = true
            } else {
                spotsAvailable = false
            }
        }
        
        if let image = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.featureImage] as? [String : AnyObject] {
            featureImageURL = image["url"] as? String
            featureImageFilePath = featureImageURL?.lastPathComponent
        }
        
    }
    
    
    func fetchImages(completionHandler: CompletionHandler) {
        guard featureImageURL != nil else {
            return
        }
        
        HacksmithsAPIClient.sharedInstance().taskForGETImageFromURL(featureImageURL!, completionHandler: {image, error in
            
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                
                self.image = image
                
            }
            
        })
    }
    
    
    var image: UIImage? {
        get {
            guard featureImageFilePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(featureImageFilePath!)
        }
        set {
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: featureImageFilePath!)
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
    
}

