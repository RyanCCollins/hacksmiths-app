//
//  Participant.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

@objc(Participant)

/** Participant model, for saving data for the participants of an event
 */
class Participant: NSManagedObject {
    @NSManaged var event: Event
    @NSManaged var idString: String
    @NSManaged var imageURLString: String?
    @NSManaged var name: String
    @NSManaged var profileURL: String
    
    /* Standard init for core data entity stuff */
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /** Init with particiapnt JSON, bridging the API data to core data
     *
     *  @param participantJSON - The JSON as received from the API to be saved by core data
     *  @param context - The managed object context to save to with core data
     *  @return None
     */
    init(participantJson: ParticipantJSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Participant", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
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
