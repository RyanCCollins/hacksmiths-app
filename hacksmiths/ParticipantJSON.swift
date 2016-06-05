//
//  ParticipantJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Ryan Collins. All rights reserved.
//

import Gloss
/** Model for storing the participants of events
 */
struct ParticipantJSON: Decodable {
    let idString: String
    let profileURL: String
    let imageURLString: String?
    let name: String
    
    init?(json: JSON) {
        guard let idString: String = "id" <~~ json,
            let profileURL: String = "url" <~~ json,
            let firstName: String = "name.first" <~~ json,
            let lastName: String = "name.last" <~~ json else {
                return nil
        }
        self.idString = idString
        self.profileURL = profileURL
        self.imageURLString = "photo" <~~ json
        self.name = "\(firstName) \(lastName)"
    }
}