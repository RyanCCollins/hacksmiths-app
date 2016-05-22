//
//  Participant.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

class Participant: NSManagedObject {
    @NSManaged var eventId: String
    @NSManaged var idString: String
    @NSManaged var imageURLString: String?
    @NSManaged var name: String
    @NSManaged var profileURL: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(participantJson: ParticipantJSON, eventID: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.eventId = eventID
        self.idString = participantJson.idString
        self.name = participantJson.name
        self.profileURL = participantJson.profileURL
        
        if let imageURL = participantJson.imageURLString {
            self.imageURLString = imageURL
        }
        self.imageURLString = participantJson.imageURLString
    }
    
    var image: UIImage? {
        get {
            guard imageFilePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(imageFilePath!)
        }
        set {
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageFilePath!)
        }
    }
    
    private var imageFilePath: String? {
        guard let imageURL = imageURLString else {
            return nil
        }
        
        return imageURL.lastPathComponent
    }
}
