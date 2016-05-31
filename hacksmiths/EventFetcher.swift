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
    
    /* - Return a promise of a fetched event, based on passed in currentEvent reference
     * - return - Promise of optional Event
     */
    func getCachedEvent(byId idString: String) -> Promise<Event?> {
        return Promise{resolve, reject in
            do {
                let eventFetch = NSFetchRequest(entityName: "Event")
                let eventPredicate = NSPredicate(format: "idString = %@", idString)
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
    
    func getCachedEvent() -> Promise<Event?> {
        return Promise{ resolve, reject in
            do {
                let sortPriority = NSSortDescriptor(key: "startDateString", ascending: false)
                let nextEventFetch = NSFetchRequest(entityName: "Event")
                nextEventFetch.sortDescriptors = [sortPriority]
                if let results = try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(nextEventFetch),
                    let event = results[0] as? Event {
                    resolve(event)
                } else {
                    resolve(nil)
                }
            }
        }
    }
    
    func deleteEvents() -> Promise<Void> {
        return Promise{resolve, reject in
            deleteAllSavedNextEventEntries().then() {
                return self.deleteAllEventEntries()
            }.then() {Void in
                 resolve()
            }.error {error in
                reject(error as NSError)
            }
        }
    }
    
    /* Next event should only hold a reference to the next event, so
     Using this convenience, all saved next event entries should be deleted when
     Creating a new one.
     */
    private func deleteAllSavedNextEventEntries() -> Promise<Void> {
        return Promise{resolve, reject in
            let fetchRequest = NSFetchRequest(entityName: "NextEvent")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: GlobalStackManager.SharedManager.sharedContext)
                resolve()
            } catch let error as NSError {
                print("An error occured while deleting all next event items.  Whoops!")
                reject(error as NSError)
            }
        }
    }
    
    private func deleteAllEventEntries() -> Promise<Void> {
        return Promise{resolve, reject in
            let fetchRequest = NSFetchRequest(entityName: "Event")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: GlobalStackManager.SharedManager.sharedContext)
                resolve()
            } catch let error as NSError {
                print("An error occured while deleting all event data")
                reject(error as NSError)
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


