//
//  ParticipantPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import CoreData

protocol ParticipantView {
    func didFetchParticipants(participants: [Participant]?)
    func noParticipantsFound()
}

class ParticipantPresenter {
    private var participantView: ParticipantView?
    
    func attachView(view: ParticipantView){
        participantView = view
    }
    
    func detachView(view: ParticipantView) {
        participantView = nil
    }
    
    /* Public API for getting list of participant from fetch */
    func getParticipants() {
        var nextEvent: NextEvent? = nil
        
        if let fetchedEvent = performNextEventFetch() {
            nextEvent = fetchedEvent
            if let participantsArray = performParticipantFetch(nextEvent!) {
                self.participantView?.didFetchParticipants(participantsArray)
            }
        }
        
        self.participantView?.noParticipantsFound()
    }
    
    private func performNextEventFetch() -> NextEvent? {
        do {
            let nextEventFetch = NSFetchRequest(entityName: "NextEvent")
            
            var returnEvent: NextEvent? = nil
            if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(nextEventFetch) as? [NextEvent] {
                guard results.count > 0 else {
                    return nil
                }
                returnEvent = results[0]
            }
            return returnEvent
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    private func performParticipantFetch(currentEvent: NextEvent) -> [Participant]? {
        do {
            let participant = NSFetchRequest(entityName: "Participant")
            let predicate = NSPredicate(format: "eventId == %@ ", currentEvent.idString)
            participant.predicate = predicate
            
            let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(participant)
            if let participantArray = results as? [Participant] {
                return participantArray
            } else {
                return nil
            }
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
}
