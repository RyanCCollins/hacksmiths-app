//
//  Reservation.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

@objc(EventRSVP)
class EventRSVP: NSManagedObject {
    @NSManaged var event: Event
    @NSManaged var who : Person
    @NSManaged var eventId: String
    @NSManaged var personId: String
    @NSManaged var updatedAt: NSDate
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("EventRSVP", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        eventId = dictionary[HacksmithsAPIClient.JSONResponseKeys.EventRSVP.eventId] as! String
        personId = dictionary[HacksmithsAPIClient.JSONResponseKeys.EventRSVP.personId] as! String
        updatedAt = dictionary[HacksmithsAPIClient.JSONResponseKeys.EventRSVP.updatedAt] as! NSDate
        
    }
    
    func batchDeleteAllRSVPS(completionHandler: CompletionHandler) {
        let fetchRequest = NSFetchRequest(entityName: "EventRSVP")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: self.sharedContext)
            sharedContext.performBlockAndWait({
                CoreDataStackManager.sharedInstance().saveContext()
            })
            
        completionHandler(success: true, error: nil)
            
        } catch let error as NSError {
            completionHandler(success: false, error: error)
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}
