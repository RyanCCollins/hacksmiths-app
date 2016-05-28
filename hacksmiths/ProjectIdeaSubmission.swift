//
//  ProjectIdeaSubmission.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

@objc(ProjectIdeaSubmission)
class ProjectIdeaSubmission: NSManagedObject {
    @NSManaged var event: String
    @NSManaged var user: String
    
    @NSManaged var title: String
    @NSManaged var descriptionString: String
    @NSManaged var additionalInformation: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(ideaSubmissionJson: ProjectIdeaSubmissionJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("ProjectIdeaSubmission", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.user = ideaSubmissionJson.user
        self.event = ideaSubmissionJson.event
        self.descriptionString = ideaSubmissionJson.idea.description
        if let additionalInformation = ideaSubmissionJson.idea.additionalInformation {
            self.additionalInformation = additionalInformation
        }
    }
    
    /* Initialize from a dictionary, since we won't always have JSON first */
    init(dictionary: JsonDict, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("ProjectIdeaSubmission", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.user = dictionary["user"] as! String
        self.event = dictionary["event"] as! String
        let idea = dictionary["idea"] as! JsonDict
        self.descriptionString = idea["description"] as! String
        self.title = idea["title"] as! String
        if let additionalInformation = idea["additionalInformation"] as? String {
            self.additionalInformation = additionalInformation
        }
    }
}
