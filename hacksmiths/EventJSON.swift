//
//  EventJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import Gloss

/* EventJSON Struct
 *
 * Handles the deserialization of JSON data from the server.
 *
 * Initialize eith JSON from EventService
 * creating an easy interface from API to Core Data Initialization
 * For Event model. Can also be used to serialize the Event model
 * at a later time if need by, utlizing the Encodable Delegate methods.
 *
 *========== Example
 * let eventJSON = EventJSON(json: JSONData)
 * let event = Event(eventJSON: eventJSON)
 *
 */
struct EventJSON: Decodable {
    /* Non optional properties */
    let idString: String
    let title: String
    let descriptionString: String
    
    let startDateString: String
    let endDateString: String
    
    /* Optional properties */
    let marketingInfo: String?
    let featureImageURL: String?
    let registrationStartDateString: String?
    let registrationEndDateString: String?
    let place: String?
    let spotsRemaining: Int
    let state: EventState?
    let organizationJSON: OrganizationJSON
    
    init?(json: JSON) {
        
        guard let eventIDString: String = EventKeys._id <~~ json,
              let title: String = EventKeys.title <~~ json,
              let descriptionString: String = EventKeys.description <~~ json,
              let startDateString: String = EventKeys.startDate <~~ json,
              let endDateString: String = EventKeys.endDate <~~ json else {
            return nil
        }
    
        self.idString = eventIDString
        self.title = title
        self.descriptionString = descriptionString.stringByRemovingHTML()
        
        self.startDateString = startDateString
        self.endDateString = endDateString
        
        let marketingData: String = (EventKeys.marketingInfo <~~ json)!
        self.marketingInfo = marketingData.stringByRemovingHTML()
        
        self.featureImageURL = EventKeys.featureImageURL <~~ json
        self.registrationStartDateString = EventKeys.registrationStartDate <~~ json
        self.registrationEndDateString = EventKeys.registrationEndDate <~~ json
        
        self.place = EventKeys.place <~~ json
        self.spotsRemaining = (EventKeys.spotsRemaining <~~ json)!
        
        self.organizationJSON = (EventKeys.organization <~~ json)!
        
        var eventState: EventState? = nil
        
        if let state: String = EventKeys.state <~~ json {
            if let currentState = EventState(rawValue: state) {
                eventState = currentState
            } else {
                eventState = nil
            }
        }
        self.state = eventState
    }
}

/* Keys used in mapping data from JSON */
struct EventKeys {
    static let _id = "_id"
    static let title = "title"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let place = "place"
    static let description = "description"
    static let marketingInfo = "marketingInfo"
    static let registrationStartDate = "registrationStartDate"
    static let registrationEndDate = "registrationEndDate"
    static let participants = "participants"
    static let featureImageURL = "featureImage.url"
    static let spotsRemaining = "spotsRemaining"
    
    static let organization = "organization"
    static let state = "state"
}