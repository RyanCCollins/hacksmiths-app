//
//  IdeaLandingPresenter
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData

protocol IdeaSubmissionView {
    func showLoading()
    func hideLoading()
    func didSubmitIdeaToAPI(sender: IdeaSubmissionPresenter, didSucceed: Bool, didFail: NSError?)
    func didFindExistingData(sender: IdeaSubmissionPresenter, ideaSubmission: ProjectIdeaSubmission)
    func isNewSubmission(sender: IdeaSubmissionPresenter)
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
        loadExistingDataIfExists()
    }
    
    func detachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = nil
        ideaSubmissionView?.unsubscribeToNotifications(self)
    }
    
    func loadExistingDataIfExists() {
        if let ideaSubmission = findExistingIdea() {
            self.ideaSubmissionView?.didFindExistingData(self, ideaSubmission: ideaSubmission)
        } else {
            self.ideaSubmissionView?.isNewSubmission(self)
        }
    }
    
    func findExistingIdea() -> ProjectIdeaSubmission? {
        do {
            let ideaFetch = NSFetchRequest(entityName: "ProjectIdeaSubmission")
            var idea: ProjectIdeaSubmission? = nil
            if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(ideaFetch) as? [ProjectIdeaSubmission] {
                guard results.count > 0 else {
                    return nil
                }
                idea = results[0]
            }
            return idea
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    func updateIdeaToAPI(projectIdea: ProjectIdeaSubmission) {
        //projectIdeaService.updateOneIdea(<#T##ideaId: String##String#>, ideaJSON: <#T##IdeaJSON#>)
    }
    
    func submitIdeaToAPI(title: String, description: String, additionalInformation: String?) {
        ideaSubmissionView?.showLoading()
        
        let ideaSubmission = createIdeaSubmission(title, description: description, additionalInformation: additionalInformation)
        
        projectIdeaService.submitIdea(ideaSubmission).then() {Void in
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: true, didFail: nil)
        }.error {error in
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: false, didFail: error as NSError)
        }
    }
    
    private func createIdeaSubmission(title: String, description: String, additionalInformation: String?) -> ProjectIdeaSubmissionJSON {
        let idea = dictionaryForIdea(title, description: description, additionalInformation: additionalInformation)
        let submission: JsonDict = [
            "user" : UserService.sharedInstance().userId!,
            "event" : "56e1e408427538030076119b",
            "idea" : idea
        ]
        let ideaSubmission = ProjectIdeaSubmission(dictionary: submission, context: GlobalStackManager.SharedManager.sharedContext)
        let ideaSubmissionJSON = ProjectIdeaSubmissionJSON(projectIdeaSubmission: ideaSubmission)
        return ideaSubmissionJSON
    }
    
    private func dictionaryForIdea(title: String, description: String, additionalInformation: String?) -> JsonDict {
        var submission: JsonDict = [
            "title": title,
            "description": description
        ]
        if let additionalInformation = additionalInformation {
            submission["additionalInformation"] = additionalInformation
        }
        return submission
    }
}
