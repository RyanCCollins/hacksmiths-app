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
        return jsonify([
            IdeaKeys.title ~~> self.title,
            IdeaKeys.description ~~> self.description,
            IdeaKeys.additionalInformation ~~> self.additionalInformation
        ])
    }
    
    func toDictionary() -> JsonDict? {
        let dictionary: JsonDict = [
            "title" : self.title,
            "description": self.description,
            "additionalInformation": self.additionalInformation!
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
    let createdBy: String
    let createdAt: NSDate?
    let event: String
    let idea: IdeaJSON?
    init?(json: JSON) {
        guard let id: String = ProjectIdeaKeys.id <~~ json,
              let createdBy: String = ProjectIdeaKeys.createdBy <~~ json,
              let event: String = ProjectIdeaKeys.event <~~ json else {
            return nil
        }
        self.id = id
        self.createdBy = createdBy
        self.event = event
        if let idea: IdeaJSON = ProjectIdeaKeys.idea <~~ json {
            self.idea = idea
        } else {
            self.idea = nil
        }
        if let createdAtString = ProjectIdeaKeys.createdAt <~~ json {
            
        }
    }
    
    // - MARK: Encode to JSON
    func toJSON() -> JSON? {
         return jsonify([
            ProjectIdeaKeys.createdBy ~~> self.createdBy,
            ProjectIdeaKeys.event ~~> self.event,
            ProjectIdeaKeys.idea ~~> self.idea
        ])
    }
    
    func toJsonDict() -> JsonDict? {
        var dictionary: JsonDict = [
            "createdBy" : self.createdBy,
            "event": self.event,
        ]
        if let ideaDict = idea?.toDictionary() {
            dictionary["idea"] = ideaDict
        }
        return dictionary
    }
}
