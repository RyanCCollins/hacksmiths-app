//
//  ParticipantJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

struct ParticipantJSON: Decodable {
    let idString: String
    let profileURL: String
    let imageURLString: String
    let name: String
    
    init?(json: JSON) {
        guard let idString: String = "id" <~~ json,
            let profileURL: String = "url" <~~ json,
            let imageURLString: String = "photo" <~~ json,
            let firstName: String = "name.first" <~~ json,
            let lastName: String = "name.last" <~~ json else {
                return nil
        }
        self.idString = idString
        self.profileURL = profileURL
        self.imageURLString = imageURLString
        self.name = "\(firstName) \(lastName)"
    }
}