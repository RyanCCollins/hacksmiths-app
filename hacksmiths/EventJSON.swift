//
//  EventJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import Gloss

struct EventKeys {
    static let _id = "_id"
    static let title = "title"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let place = "place"
    static let description = "description.md"
    static let marketingInfo = "marketingInfo.md"
    static let registrationStartDate = "registrationStartDate"
    static let registrationEndDate = "registrationEndDate"
    static let participants = "participants"
    static let featureImageURL = "featureImage.url"
    static let spotsRemaining = "spotsRemaining"
    
    static let organization = "organization"
}


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
//    let participantJSONArray: [ParticipantJSON]
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
        self.descriptionString = descriptionString
        
        self.startDateString = startDateString
        self.endDateString = endDateString
        
        self.marketingInfo = EventKeys.marketingInfo <~~ json
        self.featureImageURL = EventKeys.featureImageURL <~~ json
        self.registrationStartDateString = EventKeys.registrationStartDate <~~ json
        self.registrationEndDateString = EventKeys.registrationEndDate <~~ json
        
        self.place = EventKeys.place <~~ json
        self.spotsRemaining = (EventKeys.spotsRemaining <~~ json)!
        
        self.organizationJSON = (EventKeys.organization <~~ json)!
        
    }
}

