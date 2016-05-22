//
//  IdeaLandingPresenter
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol IdeaSubmissionView {
    func submitIdeaToAPI(sender: IdeaSubmissionPresenter, idea: ProjectIdeaJSON)
    func cancelSubmission(sender: AnyObject)
    func subscribeToNotifications(sender: AnyObject)
    func unsubscribeToNotifications(sender: AnyObject)
}

class IdeaSubmissionPresenter {
    var ideaSubmissionView: IdeaSubmissionView?
    
    func attachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = view
        ideaSubmissionView?.subscribeToNotifications(self)
    }
    
    func detachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = nil
        ideaSubmissionView?.unsubscribeToNotifications(self)
    }
    
    func submitIdeaToAPI(idea: ProjectIdea) {
        
    }
}
