//
//  EventPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation

protocol EventView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setEvent(sender: EventPresenter, didSucceed event: Event)
    func setEvent(sender: EventPresenter, didFail error: NSError)
    func setAttendees(forEvent event: Event)
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
    
    func setEvent() {
        eventService.getEventStatus.then() {
            event in
            
            self.eventView?.setEvent(self, didSucceed: event)
        }
    }
    
    private func setEventParticipants() {
        eventService.getEventAttendees.then() {
            
        }
    }
    
    func performEventFetch(completionHandler: CompletionHandler) {
        do {
            
            try fetchedResultsController.performFetch()
            completionHandler(success: true, error: nil)
        } catch let error as NSError {
            completionHandler(success: false, error: error)
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "startDate", ascending: false)
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