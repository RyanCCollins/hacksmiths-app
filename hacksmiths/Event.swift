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
    
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var organization : String?
    @NSManaged var descriptionString: String?
    @NSManaged var registrationStart : NSDate
    @NSManaged var registrationEnd : NSDate?
    @NSManaged var sponsors: [Organization]
    @NSManaged var teams: [Team]
    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var maxRSVPS: NSNumber
    @NSManaged var totalRSVPS: NSNumber
    @NSManaged var spotsAvailable: Bool
    @NSManaged var spotsRemaining: NSNumber
    
    @NSManaged var project: Project
    @NSManaged var marketingInfo: String
    
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
        id = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.id] as! String
        title = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.title] as! String
        descriptionString = dictionary[HacksmithsAPIClient.JSONResponseKeys.Event.description] as! String
        
    }
    
}
