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
//import SwiftyJSON
import Gloss

class EventService {
    func getEventStatus() -> Promise<NextEventJSON?> {
        return Promise {fullfill, reject in
            print("Calling beginning of promise in getEventStatus")
            let router = EventRouter(endpoint: .GetEventStatus())
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .Success(let JSON):
                        print("Success in event service with JSON: \(JSON)")
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
                .debugLog()
                .responseJSON {
                    response in
                    print(response.result.value)
                    switch response.result {
                    case .Success(let JSON):
                        print("Success in get event.  Saving event. \(JSON)")
                        if let eventJSONDict = JSON["event"] {
                            print("Called success in getEvent with event data: \(eventJSONDict)")
                            
                            if let eventJSON = EventJSON(json: eventJSONDict as! [String : AnyObject]) {
                                let event = Event(eventJson: eventJSON, context: GlobalStackManager.SharedManager.sharedContext)
                                
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
}

extension Request {
    
}