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
    func didReceiveNextEvent(sender: EventPresenter, nextEvent: NextEvent?, error: NSError?)
    func getEvent(sender: EventPresenter, didSucceed event: Event)
    func getEvent(sender: EventPresenter, didFail error: NSError)
    func respondToEvent(sender: EventPresenter, didSucceed event: Event)
    func respondToEvent(sender: EventPresenter, didFail error: NSError)
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
    
    
    func fetchImageForEvent(event: Event) {
        event.fetchImages().then() {
            image -> () in
            event.image = image
        }
    }
    
    /* Load in the next event and return whether there is a new event or not */
    func loadNextEvent() {
        eventService.getEventStatus().then() {
            nextEvent -> () in
            self.eventView?.didReceiveNextEvent(self, nextEvent: nextEvent, error: nil)
        }.error { error in
            self.eventView?.didReceiveNextEvent(self, nextEvent: nil, error: error as NSError)
        }
    }
    
    /* Provide a public API for getting the next event */
    func fetchNextEvent() -> NextEvent? {
        if let nextEvent = performNextEventFetch() {
            return nextEvent
        } else {
            return nil
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
                self.eventView?.getEvent(self, didSucceed: event)
            } else {
                self.eventView?.getEvent(self, didFail: GlobalErrors.MissingData)
            }
            }.error { error in
                self.eventView?.getEvent(self, didFail: error as NSError)
            }
    }
    
    private func performEventFetch() -> Event? {
        do {
            try fetchedResultsController.performFetch()
            if let event = fetchedResultsController.fetchedObjects![0] as? Event {
                return event
            } else {
                return nil
            }
        } catch let error as NSError {
            return nil
        }
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
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "startDateString", ascending: false)
        let nextEventFetch = NSFetchRequest(entityName: "Event")
        nextEventFetch.sortDescriptors = [sortPriority]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: nextEventFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
}