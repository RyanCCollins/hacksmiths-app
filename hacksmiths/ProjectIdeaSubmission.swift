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
    @NSManaged var eventModel : Event
    @NSManaged var userModel: Person
    
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
        self.descriptionString = ideaSubmissionJson.idea["description"] as! String
        if let additionalInformation = ideaSubmissionJson.idea["additionalInformation"] as? String {
            self.additionalInformation = additionalInformation
        }
    }
}
