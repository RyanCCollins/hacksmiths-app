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

class EventService {
    func getEventStatus() -> Promise<NextEventJSON?> {
        return Promise {fullfill, reject in
            print("Calling beginning of promise in getEventStatus")
            let HTTPManager = Manager()
            let router = EventRouter(endpoint: .GetEventStatus())
            HTTPManager.request(router)
                .validate()
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .Success(let JSONData):
                        print("Called success in event service")
                        let nextEventJSON = NextEventJSON(json: JSONData as! JSON)
                        fullfill(nextEventJSON)
                    case .Failure(let error):
                        print("Called reject in event service.")
                        reject(error)
                }
            }
        }
    }
    
    func getEvent(eventID: String) -> Promise<Event?> {
        return Promise {fullfill, reject in
            let HTTPManager = Manager()
            let router = EventRouter(endpoint: .GetEvent(eventID: eventID))
            HTTPManager.request(router)
                .validate()
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .Success(let JSONData):
                        
                        if let eventJSON = EventJSON(json: JSONData as! JSON) {
                            let event = Event(eventJson: eventJSON, context: GlobalStackManager.SharedManager.sharedContext)
                            
                            GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                            
                            fullfill(event)
                        } else {
                            let error = GlobalErrors.MissingData
                            reject(error)
                        }
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }
}