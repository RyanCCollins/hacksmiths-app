//
//  CurrentEventService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

class CurrentEventService {
    
    /* Singleton shared instance of */
    static let sharedService = CurrentEventService()
    
    func setFromJSON(eventJSON: NextEventJSON) {
        currentEventId = eventJSON.id
        eventIsActive = eventJSON.active
    }
    
    var currentEventId: String? {
        get {
            if let eventId = NSUserDefaults.standardUserDefaults().valueForKey("currentEventId") as? String {
                return eventId
            } else {
                return nil
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "currentEventId")
        }
    }
    
    var eventIsActive: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("eventIsActive")
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "eventIsActive")
        }
    }
}