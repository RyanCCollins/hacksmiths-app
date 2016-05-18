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
    func getEventStatus() -> Promise<Event?> {
        return Promise {fullfill, reject in
            
            let HTTPManager = Manager()
            let router = EventRouter(endpoint: .GetEventStatus())
            HTTPManager.request(router)
                .validate()
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .Success(let JSON):
                        let event = Event(json: JSON)
                        fullfill(event)
                    case .Failure(let error):
                        reject(error)
                }
            }
        }
    }
    
    func getEventAttendees(event: Event) -> Promise<[EventRSVP]?> {
        return Promise {fullfill, reject in
            
            let router = EventRouter(endpoint: .GetEventAttendees())
            let HTTPManager = Manager()
            
            
            HTTPManager.request(router)
                .validate()
                .responseJSON() {
                    response in
                    
                    switch response.result {
                    case .Success(let JSON):
                        break
                    case .Failure(let error):
                        reject(error)
                }
            }
        }
    }
}
