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
    let idea: IdeaSubmissionJSON
    
    init(projectIdeaSubmission: ProjectIdeaSubmission) {
        self.user = projectIdeaSubmission.user
        self.event = projectIdeaSubmission.event
        self.idea = IdeaSubmissionJSON(projectIdeaSubmission: projectIdeaSubmission)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "user" ~~> self.user,
            "event" ~~> self.event,
            "idea" ~~> self.idea
        ])
    }
}

struct IdeaSubmissionJSON: Encodable {
    let title: String
    let description: String
    let additionalInformation: String?
    
    init(projectIdeaSubmission: ProjectIdeaSubmission) {
        title = projectIdeaSubmission.title
        description = projectIdeaSubmission.descriptionString
        additionalInformation = projectIdeaSubmission.additionalInformation
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "title" ~~> self.title,
            "description" ~~> self.description,
            "additionalInformation" ~~> additionalInformation
        ])
    }
}

struct IdeaSubmissionKeys {
    static let title = "title"
    static let description = "description"
    static let additionalInformation = "additionalInformation"
}
