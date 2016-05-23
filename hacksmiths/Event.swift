//
//  Event.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData
import Gloss
import PromiseKit

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
        self.descriptionString = eventJson.descriptionString
        
        if let featureImageURL = eventJson.featureImageURL {
            self.featureImageURL = featureImageURL
            self.featureImageFilePath = featureImageURL.lastPathComponent
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
        
        if let marketingInfo = eventJson.marketingInfo {
            self.marketingInfo = marketingInfo
        }
        
    }

    
    /* MARK: Computed properties */
    dynamic var spotsAvailable: Bool {
        get {
            return spotsRemaining as Int > 0
        }
    }
    

    dynamic var startDate: NSDate? {
        get {
            if let date = startDateString.parseAsDate() {
                return date
            } else {
                return nil
            }
        }
    }
    
    dynamic var endDate: NSDate? {
        get {
            if let date = endDateString.parseAsDate() {
                return date
            } else {
                return nil
            }
        }
    }
    
    /* Get a formatted date string from the event
       @return - A date string formatted like: Apr 1, 16 - Apr 12, 16
     */
    var formattedDateString: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd yy"
        var start: String = ""
        var end: String = ""
        if let startDate = startDate {
            start = dateFormatter.stringFromDate(startDate)
        }
        if let endDate = endDate {
            end = dateFormatter.stringFromDate(endDate)
        }
        return "\(start) - \(end)"
    }
    
    
    func fetchImages() -> Promise<UIImage?> {
        return Promise{resolve, reject in
            guard featureImageURL != nil else {
                reject(GlobalErrors.GenericNetworkError)
                return
            }
            
            HacksmithsAPIClient.sharedInstance().taskForGETImageFromURL(featureImageURL!, completionHandler: {image, error in
                if image != nil {
                    resolve(image)
                } else {
                    reject(error! as NSError)
                }
            })
        }
    }
    
    var image: UIImage? {
        get {
            guard featureImageFilePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(featureImageFilePath!)
        }
        set {
            guard let filePath = self.featureImageFilePath else {
                return
            }
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath)
        }
    }
}
