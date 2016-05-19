//
//  EventRouter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire
import Foundation

enum EventEndpoint {
    case GetEventStatus()
    case GetEvent(eventID: String)
    case RSVPForEvent(userID: String, event: Event, participating: Bool, cancel: Bool)
}

class EventRouter: BaseRouter {
    var endpoint: EventEndpoint
    init(endpoint: EventEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetEventStatus: return .GET
        case .GetEvent: return .GET
        case .RSVPForEvent: return .POST
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetEventStatus: return "/api/app/event-status"
        case .GetEvent(let eventID): return "/api/event/\(eventID)"
        case .RSVPForEvent: return "/api/app/rsvp"
        }
    }
    
    override var parameters: JsonDict? {
        switch endpoint {
        case .RSVPForEvent(let userID, let event, let participating, let cancel):
            let eventDict: JsonDict = [
                "user": userID,
                "event": event.idString,
                "participating": participating,
                "cancel": cancel,
                "changed": currentDateTime
            ]
            return eventDict
        default:
            return nil
        }
    }
    
    var currentDateTime: String {
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let currentDateTimeString: String = dateFormatter.stringFromDate(todaysDate)
        
        return currentDateTimeString
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
        case .GetEvent: return .URL
        default: return .JSON
        }
    }
}
