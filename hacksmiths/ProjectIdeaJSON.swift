//
//  ProjectIdeaJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

struct IdeaKeys {
    static let title = "title"
    static let description = "description.md"
    static let additionalInformation = "additionalInformation"
}

struct IdeaJSON: Glossy {
    let title: String
    let description: String
    let additionalInformation: String?
    init?(json: JSON) {
        
        guard let title: String = "title" <~~ json,
            let description:String = "description" <~~ json else {
            return nil
        }
        self.title = title
        self.description = description
        self.additionalInformation = "additionalInformation" <~~ json
    }
    
    func toJSON() -> JSON? {
        let descriptionDict = ["md": description, "html": description]
        return jsonify([
            IdeaKeys.title ~~> title,
            IdeaKeys.description ~~> descriptionDict,
            IdeaKeys.additionalInformation ~~> additionalInformation
        ])
    }
    
    func toDictionary() -> JsonDict? {
        let dictionary: JsonDict = [
            "title" : self.title,
            "description": self.description,
            "additionalInformation": self.additionalInformation! ?? ""
        ]
        return dictionary
    }
}

struct ProjectIdeaKeys {
    static let id = "_id"
    static let createdBy = "createdBy"
    static let createdAt = "createdAt"
    static let event = "event"
    static let idea = "idea"
}

struct ProjectIdeaJSON: Glossy {
    let id: String
    let createdById: String
    var createdAt: NSDate? = nil
    let eventId: String
    let idea: IdeaJSON?
    
    init?(json: JSON) {
        guard let id: String = ProjectIdeaKeys.id <~~ json,
              let createdById: String = ProjectIdeaKeys.createdBy <~~ json,
              let eventId: String = ProjectIdeaKeys.event <~~ json else {
            return nil
        }
        self.id = id
        self.createdById = createdById
        self.eventId = eventId
        if let idea: IdeaJSON = ProjectIdeaKeys.idea <~~ json {
            self.idea = idea
        } else {
            self.idea = nil
        }
        
        if let createdAtString: String = ProjectIdeaKeys.createdAt <~~ json {
            if let date = createdAtString.parseAsDate() {
                self.createdAt = date
            }
        }
        
    }
    
    // - MARK: Encode to JSON
    func toJSON() -> JSON? {
         return jsonify([
            ProjectIdeaKeys.createdBy ~~> self.createdById,
            ProjectIdeaKeys.event ~~> self.eventId,
            ProjectIdeaKeys.idea ~~> self.idea?.toJSON()
        ])
    }
}
