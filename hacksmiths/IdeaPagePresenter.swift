//
//  IdeaPagePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Ryan Collins. All rights reserved.
//

/** MVP Protocol for idea page view
 */
protocol IdeaPageView {
    func submitAnIdea(sender: IdeaPagePresenter)
    func didLoadNextEvent(sender: IdeaPagePresenter, didSucceed nextEvent: NextEvent?, didFail error: NSError?)
}

/** Idea Page Presenter, handles the communication with the model for the idea page view.
 */
class IdeaPagePresenter {
    private var ideaPageView: IdeaPageView?
    private var eventService: EventService?
    
    func attachView(view: IdeaPageView, eventService: EventService) {
        ideaPageView = view
        self.eventService = eventService
    }
    
    func detachView(view: IdeaPageView) {
        ideaPageView = nil
        self.eventService = nil
    }
    
    func submitAnIdea() {
        
    }
    
    /** Load the current event from the cache
     *
     *  @param None
     *  @return None
     */
    func loadCurrentEvent() {
        EventFetcher.sharedFetcher.performNextEventFetch().then() {
            nextEvent -> () in
            if nextEvent != nil {
                self.ideaPageView?.didLoadNextEvent(self, didSucceed: nextEvent, didFail: nil)
            } else {
                self.ideaPageView?.didLoadNextEvent(self, didSucceed: nil, didFail: nil)
            }
        }.error{error in
            self.ideaPageView?.didLoadNextEvent(self, didSucceed: nil, didFail: error as NSError)
        }
    }
    
    /** Check the API for the event in case one is not fetched
     *
     *  @param None
     *  @return None
     */
    func checkAPIForEvent() {
        if let eventService = eventService {
            eventService.getEventStatus().then() {
                nextEvent -> () in
                if nextEvent != nil {
                    self.ideaPageView?.didLoadNextEvent(self, didSucceed: nextEvent, didFail: nil)
                } else {
                    self.ideaPageView?.didLoadNextEvent(self, didSucceed: nil, didFail: nil)
                }
                }.error {error in
                    self.ideaPageView?.didLoadNextEvent(self, didSucceed: nil, didFail: error as NSError)
                }
        }
    }
}
