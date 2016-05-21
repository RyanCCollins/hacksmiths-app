//
//  ProjectIdea.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
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
        
    }
}
