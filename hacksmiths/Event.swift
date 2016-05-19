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
    /* Non Optional props */
    @NSManaged var idString: String
    @NSManaged var title: String
    @NSManaged var descriptionString: String
    @NSManaged var startDateString: String
    @NSManaged var endDateString: String
    
    /* Optional Props */
    @NSManaged var marketingInfo: String?
    @NSManaged var featureImageURL: String?
    @NSManaged var registrationStartDateString : String?
    @NSManaged var registrationEndDateString : String?
    @NSManaged var place: String?
    @NSManaged var spotsRemaining: NSNumber
    @NSManaged var participants: [Participant]
    
    /* Other props that need to get set from non JSON */
    @NSManaged var featureImageFilePath: String?
    @NSManaged var active: Bool
    
    @NSManaged var organization : Organization?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(eventJson: EventJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.idString = eventJson.idString
        self.title = eventJson.title
        self.startDateString = eventJson.startDateString
        self.endDateString = eventJson.endDateString
        
        if let featureImageURL = eventJson.featureImageURL {
            self.featureImageURL = featureImageURL
        }
        
        if let registrationStartDateString = eventJson.registrationStartDateString {
            self.registrationStartDateString = registrationStartDateString
        }
        
        if let registrationEndDateString = eventJson.registrationEndDateString {
            self.registrationEndDateString = registrationEndDateString
        }
        
        if let place = eventJson.place {
            self.place = place
        }
        
        /* Create related models from embedded JSON */
        self.participants = createParticipantModel(eventJson.participantJSONArray, eventID: self.idString)
        self.organization = createOrganizationModel(eventJson.organizationJSON, eventID: self.idString)
    }
    
    private func createParticipantModel(participantJSONArray: [ParticipantJSON], eventID: String) -> [Participant] {
        return participantJSONArray.map({participant in
            return Participant(participantJson: participant, eventID: eventID, context: GlobalStackManager.SharedManager.sharedContext)
        })
    }
    
    private func createOrganizationModel(organizationJSON: OrganizationJSON, eventID: String) -> Organization {
        let organization = Organization(entity: organizationJSON, insertIntoManagedObjectContext: GlobalStackManager.SharedManager.sharedContext)
        
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
