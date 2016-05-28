//
//  NextEvent.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/22/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

@objc(NextEvent)
class NextEvent: NSManagedObject {
    @NSManaged var idString: String
    @NSManaged var active: Bool
    
    required override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    init(nextEventJSON: NextEventJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("NextEvent", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.idString = nextEventJSON.id
        self.active = nextEventJSON.active
    }
}
