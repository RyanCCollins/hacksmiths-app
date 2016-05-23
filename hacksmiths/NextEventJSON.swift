//
//  NextEventJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/19/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

/* Next event, when checking event status.  Will allow to get next event by ID. */
struct NextEventJSON: Decodable {
    let id: String
    let active: Bool
    
    init?(json: JSON) {
        guard let id: String = "id" <~~ json,
            let active: Bool = "active" <~~ json else {
                return nil
        }
        self.id = id
        self.active = active
    }
}