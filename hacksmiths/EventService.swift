//
//  EventService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Gloss
import CoreData

class EventService {
    func getEventStatus() -> Promise<NextEvent?> {
        return Promise {resolve, reject in
            print("Calling beginning of promise in getEventStatus")
            let router = EventRouter(endpoint: .GetEventStatus())
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .Success(let JSON):
                        if let nextEventData = JSON["event"] as? JsonDict,
                            let nextEventJSON = NextEventJSON(json: nextEventData) {
                            
                            self.deleteAllSavedNextEventEntries()
                            let nextEvent = NextEvent(nextEventJSON: nextEventJSON, context: GlobalStackManager.SharedManager.sharedContext)
                            
                            /* Save the context for this next event model object */
                            GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                            resolve(nextEvent)
                        } else {
                            reject(GlobalErrors.MissingData)
                        }
                    case .Failure(let error):
                        print("Called reject in event service.")
                        reject(error)
                }
            }
        }
    }
    
    func getEvent(eventID: String) -> Promise<Event?> {
        return Promise {fullfill, reject in
            let router = EventRouter(endpoint: .GetEvent(eventID: eventID))
            HTTPManager.sharedManager.request(router)
                .responseJSON {
                    response in
                    print(response.result.value)
                    switch response.result {
                    case .Success(let JSON):
                        print("Success in get event.  Saving event. \(JSON)")
                        if let eventJSONDict = JSON["event"] {
                            print("Called success in getEvent with event data: \(eventJSONDict)")
                            
                            if let eventJSON = EventJSON(json: eventJSONDict as! [String : AnyObject]) {
                                
                                /* Handle parsing the participant array and create the event model */
                                /* BOOM */
                                let participantJSON = JSON["participants"] as! [JsonDict]
                                let participantJSONArray = [ParticipantJSON].fromJSONArray(participantJSON)
                                
                                let event = Event(eventJson: eventJSON, participantJSONArray: participantJSONArray, context: GlobalStackManager.SharedManager.sharedContext)
                                
                                GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                    CoreDataStackManager.sharedInstance().saveContext()
                                })
                                fullfill(event)
                            }
                        } else {
                            reject(GlobalErrors.GenericError)
                        }
                    case .Failure(let error):
                        print("error in get event \(error.code)")
                        
                        reject(error)
                    }
            }
        }
    }
    
    /* Next event should only hold a reference to the next event, so
     Using this convenience, all saved next event entries should be deleted when
     Creating a new one.
     */
    private func deleteAllSavedNextEventEntries() {
        let fetchRequest = NSFetchRequest(entityName: "NextEvent")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: GlobalStackManager.SharedManager.sharedContext)
        } catch let error as NSError {
            print("An error occured while deleting all next event items.  Whoops!")
        }
    }
}
