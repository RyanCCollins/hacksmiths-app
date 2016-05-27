//
//  IdeaLandingPresenter
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol IdeaSubmissionView {
    func showLoading()
    func hideLoading()
    func didSubmitIdeaToAPI(sender: IdeaSubmissionPresenter, didSucceed: Bool, didFail: NSError?)
    func cancelSubmission(sender: AnyObject)
    func subscribeToNotifications(sender: AnyObject)
    func unsubscribeToNotifications(sender: AnyObject)
}

class IdeaSubmissionPresenter {
    var ideaSubmissionView: IdeaSubmissionView?
    private let projectIdeaService: ProjectIdeaService
    
    init(projectIdeaService: ProjectIdeaService) {
        self.projectIdeaService = projectIdeaService
    }
    
    func attachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = view
        ideaSubmissionView?.subscribeToNotifications(self)
    }
    
    func detachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = nil
        ideaSubmissionView?.unsubscribeToNotifications(self)
    }
    
    func submitIdeaToAPI(ideaDictionary: JsonDict) {
        ideaSubmissionView?.showLoading()
        if let ideaSubmission = dictionaryForSubmission(ideaDictionary) {
            let ideaSubmissionJSON = ProjectIdeaSubmissionJSON(dictionary: ideaSubmission)
            projectIdeaService.submitIdea(ideaSubmissionJSON).then() {
                Void in
                    self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: true, didFail: nil)
                }.error { error in
                    self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: false, didFail: error as NSError)
                }
        } else {
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: false, didFail: GlobalErrors.MissingData)
        }
    }
    
    /* Ensure that there is an event to submit ideas for and that the user is signed in,
        otherwise, return nil for the submission */
    func dictionaryForSubmission(idea: JsonDict) -> JsonDict? {
        guard let event = EventFetcher.sharedFetcher.fetchCurrentEvent(),
            user = UserService.sharedInstance().userId else {
                return nil
        }
        let jsonDict: JsonDict = [
            "idea" : idea,
            "event" : event,
            "user" : user
        ]
        return jsonDict
    }
}
