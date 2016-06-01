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
    func didReceiveNewEvent(sender: EventPresenter, didSucceed event: NextEvent?, error: NSError?)
    func didLoadCachedEvent(sender: EventPresenter, didSucceed event: Event?, error: NSError?)
    func didReceiveEventData(sender: EventPresenter, didSucceed event: Event?, didFail error: NSError?)
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
    
    func fetchCachedEvent() {
        EventFetcher.sharedFetcher.getCachedEvent().then() {
            event -> () in
            if event != nil {
                self.eventView?.didLoadCachedEvent(self, didSucceed: event!, error: nil)
            } else {
                self.eventView?.didLoadCachedEvent(self, didSucceed: nil, error: nil)
            }
            }.error {error in
                self.eventView?.didLoadCachedEvent(self, didSucceed: nil, error: error as NSError)
            }
    }
    
    func fetchNextEvent() {
        eventView?.startLoading()
        EventFetcher.sharedFetcher.deleteEvents().then() {
            self.eventService.getEventStatus().then() {
                nextEvent -> () in
                if nextEvent != nil {
                    self.eventView?.didReceiveNewEvent(self, didSucceed: nextEvent, error: nil)
                } else {
                    self.eventView?.didReceiveNewEvent(self, didSucceed: nil, error: nil)
                }
                }.error {error in
                    self.eventView?.didReceiveNewEvent(self, didSucceed: nil, error: error as NSError?)
            }
        }
    }
    
    func fetchEventData(eventId: String) {
        eventView?.startLoading()
        self.eventService.getEvent(eventId).then() {
            event -> () in
                if event != nil {
                    self.fetchImageForEvent(event!)
                    self.eventView?.didReceiveEventData(self, didSucceed: event, didFail: nil)
                } else {
                    self.eventView?.didReceiveEventData(self, didSucceed: nil, didFail: nil)
                }
            }.error{error in
                self.eventView?.didReceiveEventData(self, didSucceed: nil, didFail: error as NSError)
            }
    }
}
