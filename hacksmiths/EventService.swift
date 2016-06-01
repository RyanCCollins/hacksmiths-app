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
    /* Get Event status, checking the API for a new event
     * @params - None
     * @return - Promise<NextEvent?> - A promise of optional Next Event (temporary description of the next event stored to Core Data.)
     */
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
                            
                            var nextEvent: NextEvent? = nil
                            /* Save the context for this next event model object */
                            GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                nextEvent = NextEvent(nextEventJSON: nextEventJSON, context: GlobalStackManager.SharedManager.sharedContext)
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                            if let nextEvent = nextEvent {
                                resolve(nextEvent)
                            } else {
                                reject(GlobalErrors.MissingData)
                            }
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
    
    /* Get an event from the API by ID
     * @params - Event ID - the event ID being fetched, which is received from the next event cache
     * @return - Promise<Event?> - A promise of optional Event
     */
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
                                
                                /** Handle parsing the participant array and create the event model. Careful, this may explode
                                 *
                                 */
                                GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({

                                    let participantJSON = JSON["participants"] as! [JsonDict]
                                    let participantJSONArray = [ParticipantJSON].fromJSONArray(participantJSON)
                                    let event = Event(eventJson: eventJSON, context: GlobalStackManager.SharedManager.sharedContext)
                                    CoreDataStackManager.sharedInstance().saveContext()
                                    
                                    if participantJSONArray.count > 0 {
                                        self.createParticipantModel(participantJSONArray, event: event)
                                    }
                                    
                                    if let organization = self.createOrganizationModel(eventJSON.organizationJSON, eventID: event.idString) {
                                        event.organization = organization
                                    }
                                    CoreDataStackManager.sharedInstance().saveContext()
                                    fullfill(event)
                                })
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
    
    /* Post an RSVP to the API
     * @params - Event - the event being RSVP'd to
     * @params - User Id - the user posting (requires authentication)
     * @return - Promise<Void> - A promise of type Void.
     */
    func postRSVP(forEvent event: Event, userId: String) -> Promise<Void> {
        return Promise{resolve, reject in
            let router = EventRouter(endpoint: .RSVPForEvent(userID: userId, event: event, participating: true, cancel: false))
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON{
                    response in
                    switch response.result {
                    case .Success:
                        resolve()
                    case .Failure(let error):
                        reject(error as NSError)
                    }
            }
        }
    }
    
    private func createParticipantModel(participantJSONArray: [ParticipantJSON], event: Event) {
        let participants = participantJSONArray.map({participant in
            return Participant(participantJson: participant, context: GlobalStackManager.SharedManager.sharedContext)
        })
    
        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
            CoreDataStackManager.sharedInstance().saveContext()
        })
        
        for participant in participants {
            participant.event = event
        }
        
        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
            CoreDataStackManager.sharedInstance().saveContext()
        })
    }
    
    private func createOrganizationModel(organizationJSON: OrganizationJSON, eventID: String) -> Organization? {
        let organization = Organization(organizationJSON: organizationJSON, eventID: eventID, context: GlobalStackManager.SharedManager.sharedContext)
        
        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
            CoreDataStackManager.sharedInstance().saveContext()
        })
        
        return organization
    }
}


