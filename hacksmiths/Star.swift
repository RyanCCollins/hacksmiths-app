//
//  Star.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/30/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

class Star: NSManagedObject {
    @NSManaged var person: Person
    @NSManaged var user: UserData
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(person: Person, user: UserData, context: NSManagedObjectContext) {
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("Star", inManagedObjectContext: context)
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.person = person
        self.user = user
    }
}
