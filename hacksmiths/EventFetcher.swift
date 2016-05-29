//
//  EventFetcher.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData
import PromiseKit

class EventFetcher {
    static let sharedFetcher = EventFetcher()
    
//    
//    func fetchCurrentEvent() -> NextEvent? {
//        var returnEvent: NextEvent? = nil
//        performNextEventFetch().then(){
//            nextEvent -> () in
//            returnEvent = nextEvent != nil ? nextEvent : nil
//        }
//        return returnEvent
//    }
    
    
    /* - Return a promise of a fetched event, based on passed in currentEvent reference
     * - return - Promise of optional Event
     */
    func performEventFetch(currentEvent: NextEvent) -> Promise<Event?> {
        return Promise{resolve, reject in
            do {
                let eventFetch = NSFetchRequest(entityName: "Event")
                let eventPredicate = NSPredicate(format: "idString = %@", currentEvent.idString)
                eventFetch.predicate = eventPredicate
                
                
                if let results = try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(eventFetch),
                    event = results[0] as? Event {
                    resolve(event)
                } else {
                    resolve(nil)
                }
            }
        }
    }
    
    /* - Return a promise of the next (currently save) Event
     * - return - Promise of optional NextEvent
     */
    func performNextEventFetch() -> Promise<NextEvent?> {
        return Promise{resolve, reject in
            do {
                let nextEventFetch = NSFetchRequest(entityName: "NextEvent")
                
                var returnEvent: NextEvent? = nil
                if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(nextEventFetch) as? [NextEvent] {
                    guard results.count > 0 else {
                        resolve(nil)
                        return
                    }
                    returnEvent = results[0]
                }
                resolve(returnEvent)
            } catch let error as NSError {
                reject(error)
            }
        }
    }
}


