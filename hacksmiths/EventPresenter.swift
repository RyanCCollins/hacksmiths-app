//
//  EventPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import CoreData

protocol EventView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
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
    
    func getNextEvent() {
        eventService.getEventStatus().then() {
            nextEvent -> () in
            

            self.eventService.getEvent(nextEvent!.id).then(){
                event -> () in
                
                self.eventView?.getEvent(self, didSucceed: event!)
            }
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