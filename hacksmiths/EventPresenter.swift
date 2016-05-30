//
//  EventPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

protocol EventView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func didReceiveNewEvent(sender: EventPresenter, newEvent: NextEvent?, error: NSError?)
    func didLoadCachedEvent(event: Event)
    func didReceiveEventData(sender: EventPresenter, didSucceed event: Event?, didFail error: NSError?)
    func handleSetDebugMessage(message: String)
//    func getEvent(sender: EventPresenter, didSucceed event: Event)
//    func getEvent(sender: EventPresenter, didFail error: NSError)
    func didRSVPForEvent(sender: EventPresenter, success: Bool, error: NSError?)
}

class EventPresenter {
    private var eventView: EventView?
    private let eventService: EventService
    
    init(eventService: EventService) {
        self.eventService = eventService
    }
    
    func attachView(view: EventView) {
        eventView = view
    }
    
    func detachView() {
        eventView = nil
    }
    
    /* Post an RSVP to the API through the eventService
     * Sends a message to the eventView delegate upon completion
     * @params - Event - the event being RSVP'd to
     */
    func rsvpForEvent(event: Event) {
        if UserService.sharedInstance().authenticated == true {
            eventService
                .postRSVP(forEvent: event, userId: UserService.sharedInstance().userId!)
                .then() { Void in
                self.eventView?.didRSVPForEvent(self, success: true, error: nil)
            }.error{ error in
                self.eventView?.didRSVPForEvent(self, success: false, error: error as NSError)
            }
        }
    }
    
    func fetchImageForEvent(event: Event) {
        event.fetchImages().then() {
            image -> () in
            event.image = image
        }
    }
    
    func fetchAndCheckAPIForEvent() {
        // 1. Check if there is a fetched event and load it.
        if let event = performEventFetch() {
            self.eventView?.didLoadCachedEvent(event)
            
            // 2. Check the API to see if there is a new event.  If the event is the same as the fetched one, stop.
            eventService.fetchNextEventIfStatusChanged(event).then() {
                nextEvent -> () in
                
                    if nextEvent != nil {
                        // 3. If the event is different, then alert the view, which will handle fetching the data.
                        self.eventView?.didReceiveNewEvent(self, newEvent: nextEvent, error: nil)
                    }
                }.error {error in
                    // 4. Handle the case that there is an error.
                    self.eventView?.didReceiveNewEvent(self, newEvent: nil, error: error as NSError)
                }
            
        } else {
            eventService.getEventStatus().then{
                nextEvent -> () in
                let eventId = nextEvent?.idString
                self.getEventData(eventId!)
            }.error {error in
                self.eventView?.didReceiveEventData(self, didSucceed: nil, didFail: error as NSError)
            }
        }
        
    }


    
    func getEventData(nextEventId: String) {
        eventService.getEvent(nextEventId).then() {
            event -> () in
            guard event != nil else {
                throw GlobalErrors.MissingData
            }
            if let event = self.performEventFetch() {
                self.fetchImageForEvent(event)
                self.eventView?.didReceiveEventData(self, didSucceed: event, didFail: nil)
            } else {
                self.eventView?.didReceiveEventData(self, didSucceed: nil, didFail: GlobalErrors.MissingData)
            }
            }.error { error in
                self.eventView?.didReceiveEventData(self, didSucceed: nil, didFail: error as NSError)
            }
    }
    
    
    private func performEventFetch() -> Event? {
        do {
            try fetchedResultsController.performFetch()
            var returnEvent: Event? = nil
            if fetchedResultsController.fetchedObjects?.count > 0 {
                if let event = fetchedResultsController.fetchedObjects![0] as? Event {
                    returnEvent = event
                }
            }
            return returnEvent
        } catch let error as NSError {
            return nil
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "startDateString", ascending: false)
        let nextEventFetch = NSFetchRequest(entityName: "Event")
        nextEventFetch.sortDescriptors = [sortPriority]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: nextEventFetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
}