//
//  ProjectIdea.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Ryan Collins. All rights reserved.
//

import CoreData

class ProjectIdea: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var event: Event
    @NSManaged var createdBy: Person
    @NSManaged var createdAt: NSDate
    @NSManaged var title: String
    @NSManaged var descriptionString: String
    @NSManaged var additionalInformation: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(ideaJSON: ProjectIdeaJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("ProjectIdea", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.id = ideaJSON.id
        
        
        /* Assign the information for the idea */
        if let idea = ideaJSON.idea {
            self.title = idea.title
            self.descriptionString = idea.description
            self.additionalInformation = idea.additionalInformation
        }
        
        /* Set the created at date to current date or the date returned from API */
        if let createdAt = ideaJSON.createdAt {
            self.createdAt = createdAt
        } else {
            self.createdAt = getCurrentDate()
        }
    }
    
    private func getCurrentDate() -> NSDate {
        let date = NSDate()
        return date
    }
}
