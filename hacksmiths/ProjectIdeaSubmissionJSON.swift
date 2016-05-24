//
//  ProjectIdeaSubmissionJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

struct ProjectIdeaSubmissionJSON: Encodable {
    let user: String
    let event: String
    let idea: JSON
    
    init(projectIdeaSubmission: ProjectIdeaSubmission) {
        self.user = projectIdeaSubmission.user
        self.event = projectIdeaSubmission.event
        var ideaDict: JSON = [
            "title" : projectIdeaSubmission.title,
            "description" : projectIdeaSubmission.descriptionString,
            ]
        if let additionalInformation = projectIdeaSubmission.additionalInformation {
            ideaDict["additionalInformation"] = additionalInformation
        }
        self.idea = ideaDict
    }
    
    init(dictionary: JsonDict) {
        self.user = dictionary["user"] as! String
        self.event = dictionary["event"] as! String
        self.idea = dictionary["idea"] as! JsonDict
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "user" ~~> self.user,
            "event" ~~> self.event,
            "idea" ~~> self.idea
        ])
    }
}
