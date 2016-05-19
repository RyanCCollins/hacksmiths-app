//
//  OrganizationJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

struct OrganizationKeys {
    static let _id = "_id"
    static let name = "name"
    static let isHiring = "isHiring"
    static let website = "website"
    static let description = "description.md"
    static let logoURL = "logo.url"
}

class OrganizationJSON: Decodable {
    let idString: String
    let name: String
    let isHiring: Bool
    let website: String?
    let descriptionString: String?
    let logoURL: String?
    
    init?(json: JSON) {
        guard let id: String = OrganizationKeys._id <~~ json,
            let name: String = OrganizationKeys.name <~~ json,
            let isHiring: Bool = OrganizationKeys.isHiring <~~ json else {
                return nil
        }
        self.idString = id
        self.name = name
        self.isHiring = isHiring
        
        self.website = OrganizationKeys.website <~~ json
        self.logoURL = OrganizationKeys.logoURL <~~ json
    }
}
