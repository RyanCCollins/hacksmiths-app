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
    @NSManaged var idString: String
    @NSManaged var title: String
    @NSManaged var descriptionString: String
    @NSManaged var additionalInformation: String?
    
    /** Standard Core Data initializer for idea submission (submit by a user, not from API)
     *
     *  @param entity - the NSEntityDescription for the managed object model
     *  @param context - the Managed object context
     *  @return None
     */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /** Initializer from JSON to Core Data Managed Object
     *
     *  @param ideaSubmissionJson - A JSON object representing one idea submission
     *  @param idString - the idString of the idea
     *  @param context - the Managed Object Context to save the model to
     *  @return None
     */
    init(ideaSubmissionJson: ProjectIdeaSubmissionJSON, idString: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("ProjectIdeaSubmission", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.idString = idString
        self.user = ideaSubmissionJson.user
        self.event = ideaSubmissionJson.event
        self.title = ideaSubmissionJson.idea.title
        self.descriptionString = ideaSubmissionJson.idea.description
        if let additionalInformation = ideaSubmissionJson.idea.additionalInformation {
            self.additionalInformation = additionalInformation
        }
    }
    
    /** Convenience initializer for creating the model with a dictionary vs. JSON since it's possible that
     *  We will need to initalize using a dictionary rather than from JSON.
     *
     *  @param dictionary - [String : AnyObject] - The dictionary to initialize the data with
     *  @param context - the managed object context to intialize from.
     *  @return None
     */
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
