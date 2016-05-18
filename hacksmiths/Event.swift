//
//  Event.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData
import Gloss

@objc(Event)


class Event: NSManagedObject {
    
    @NSManaged var eventID: String
    @NSManaged var title: String
    @NSManaged var organization : Organization?
    @NSManaged var descriptionString: String?
    @NSManaged var registrationStartDateString : String?
    @NSManaged var registrationEndDateString : String?
    
    @NSManaged var startDateString: String
    @NSManaged var endDateString: String
    @NSManaged var active: Bool
    
    @NSManaged var maxRSVPS: NSNumber
    @NSManaged var totalRSVPS: NSNumber
    
    @NSManaged var spotsRemaining: NSNumber
    
    @NSManaged var marketingInfo: String
    
    @NSManaged var featureImageURL: String?
    @NSManaged var featureImageFilePath: String?
    @NSManaged var participants: [Person]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(eventJson: EventJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.eventID = eventJson.eventID
        self.title = eventJson.title
        self.descriptionString = eventJson.descriptionString
        self.registrationEndDateString = eventJson.registrationEndString
        self.registrationStartDateString = eventJson.registrationEndString
        self.startDateString = eventJson.startDateString
        self.endDateString = eventJson.endDateString
        self.featureImageURL = eventJson.featureImageURL
        self.marketingInfo = eventJson.m
    }
    
//    /* Custom init */
//    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
//        
//        /* Get associated entity from our context */
//        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
//        
//        /* Super, get to work! */
//        super.init(entity: entity!, insertIntoManagedObjectContext: context)
//        
//        /* Assign our properties */
//        eventID = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.id] as! String
//        title = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.title] as! String
//        descriptionString = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.description] as? String
//        
//        
//        if let spots = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.spotsRemaining] as? Int {
//            spotsRemaining = spots
//            if spots > 0 {
//                spotsAvailable = true
//            } else {
//                spotsAvailable = false
//            }
//        }
//        
//        active = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.active] as! Bool
//        
//        if let eventEndDate = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.ends] as? NSDate {
//            endDate = eventEndDate
//        }
//        
//        if let eventStartDate = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.starts] as? NSDate {
//            startDate = eventStartDate
//        }
//        
//        if let registrationStartDate = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.registrationStartDate] as? NSDate {
//            registrationStart = registrationStartDate
//        }
//        
//        if let registrationEndDate = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.registrationEndDate] as? NSDate {
//            registrationEnd = registrationEndDate
//        }
//        
//        if let imageURL = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.featureImage] as? String {
//            featureImageURL = imageURL
//            featureImageFilePath = featureImageURL?.lastPathComponent
//        }
//        
//    }
//
  
    
    
    /* MARK: Computed properties */
    dynamic var spotsAvailable: Bool {
        get {
            return spotsRemaining as Int > 0
        }
    }
    
    internal func dateFromString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = ""
        let date = dateFormatter.dateFromString(string)
        return (date == nil ? nil : date)!
    }
    
    dynamic var startDate: NSDate {
        get {
            return dateFromString(self.startDateString as String)
        }
    }
    
    dynamic var endDate: NSDate {
        get {
            return dateFromString(self.endDateString as String)
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
}
