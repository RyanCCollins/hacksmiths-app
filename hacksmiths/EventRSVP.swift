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
    // Note: for the time being, we are just storing the eventID and personId
    // But we should keep the model with the relationships for later use
    @NSManaged var event: Event?
    @NSManaged var who : Person?
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
        
        let eventId = dictionary[HacksmithsAPIClient.JSONResponseKeys.EventRSVP.eventId] as! String
        let personId = dictionary[HacksmithsAPIClient.JSONResponseKeys.EventRSVP.personId] as! String
        
        if let person = findPerson(fromId: personId) {
            who = person
        }
        
        if let theEvent = findEvent(fromId: eventId) {
            event = theEvent
        }
        
    }
    
    func findEvent(fromId id: String)-> Event?{
        let fetchPredicate = NSPredicate(format: "eventID == %@", id)
        let fetchRequest = NSFetchRequest(entityName: "Event")
        fetchRequest.predicate = fetchPredicate
        
        do {
            let fetchedObjects = try sharedContext.executeFetchRequest(fetchRequest)
            
            if fetchedObjects.count > 0 {
                
                if let theEvent = fetchedObjects[0] as? Event {
                    return theEvent
                } else {
                    
                    return nil
                }
            
            } else {
                return nil
            }
            
        } catch let error as NSError {
            print("Error setting event in EventRSVPs")
            return nil
            
        }
    
    }
    
    func findPerson(fromId id: String) -> Person? {
        let fetchPredicate = NSPredicate(format: "id == %@", id)
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.predicate = fetchPredicate
        
        do {
            let fetchedObjects = try sharedContext.executeFetchRequest(fetchRequest)
            
            if let thePerson = fetchedObjects[0] as? Person {
                return thePerson
            } else {
                return nil
            }
            
        } catch let error as NSError {
            print("Error fetching events in EventRSVP")
            return nil
        }

    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}
