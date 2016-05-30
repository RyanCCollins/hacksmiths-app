//
//  EnrollmentJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

struct EnrollmentKeys {
    static let id = "id"
    static let title = "title"
    static let description = "description"
    static let logo = "logo"
    static let link = "link"
    static let updatedAt = "updatedAt"
}

struct EnrollmentJSON: Decodable {
    let id: String
    let title: String
    let description: String?
    let logo: String?
    let link: String?
    let updatedAt: String?
    
    init?(json: JSON) {
        guard let id: String = EnrollmentKeys.id <~~ json,
        let title: String = EnrollmentKeys.title <~~ json,
            let description: String = EnrollmentKeys.description <~~ json else {
                return nil
        }
        self.id = id
        self.title = title
        self.description = description
        if let logo: String = EnrollmentKeys.logo <~~ json {
            self.logo = logo
        } else {
            self.logo = nil
        }
        if let link: String = EnrollmentKeys.link <~~ json {
            self.link = link
        } else {
            self.link = nil
        }
        
        if let date: String = EnrollmentKeys.updatedAt <~~ json {
            self.updatedAt = date
        } else {
            self.updatedAt = nil
        }
        
    }
}
