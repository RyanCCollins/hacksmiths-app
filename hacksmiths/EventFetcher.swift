//
//  EventFetcher.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

class EventFetcher {
    static let sharedFetcher = EventFetcher()
    
    func fetchCurrentEvent() -> Event? {
        if let currentEvent = performNextEventFetch(),
                event = performEventFetch(currentEvent) {
                return event
        } else {
            return nil
        }
    }
    
    private func performEventFetch(currentEvent: NextEvent) -> Event? {
        do {
            let eventFetch = NSFetchRequest(entityName: "Event")
            let eventPredicate = NSPredicate(format: "idString = %@", currentEvent.idString)
            eventFetch.predicate = eventPredicate
            
            
            if let results = try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(eventFetch),
                    event = results[0] as? Event {
                
                return event
            } else {
                return nil
            }
        }
    }
    
    private func performNextEventFetch() -> NextEvent? {
        do {
            let nextEventFetch = NSFetchRequest(entityName: "NextEvent")
            
            var returnEvent: NextEvent? = nil
            if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(nextEventFetch) as? [NextEvent] {
                guard results.count > 0 else {
                    return nil
                }
                returnEvent = results[0]
            }
            return returnEvent
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
