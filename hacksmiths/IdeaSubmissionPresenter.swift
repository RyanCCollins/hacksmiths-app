//
//  IdeaLandingPresenter
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Ryan Collins. All rights reserved.
//

import CoreData
import PromiseKit

/** Protocol to follow the MVP pattern for Idea Submission.
 */
protocol IdeaSubmissionView {
    func startLoading()
    func finishLoading()
    func didSubmitIdeaToAPI(sender: IdeaSubmissionPresenter, didSucceed: Bool, didFail: NSError?)
    func didFindExistingData(sender: IdeaSubmissionPresenter, ideaSubmission: ProjectIdeaSubmission)
    func isNewSubmission(sender: IdeaSubmissionPresenter)
    func cancelSubmission(sender: AnyObject)
    func subscribeToNotifications(sender: AnyObject)
    func unsubscribeToNotifications(sender: AnyObject)
}

/** Idea Submission Presenter - Handles communicating with model layer for view
 */
class IdeaSubmissionPresenter {
    var ideaSubmissionView: IdeaSubmissionView?
    private let projectIdeaService: ProjectIdeaService
    
    init(projectIdeaService: ProjectIdeaService) {
        self.projectIdeaService = projectIdeaService
    }
    
    /** Attach the view to the presenter and perform the setup
     */
    func attachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = view
        ideaSubmissionView?.subscribeToNotifications(self)
        loadExistingDataIfExists()
    }
    
    /** Detach the view from the presenter and do any breakdown needed
     */
    func detachView(view: IdeaSubmissionView) {
        self.ideaSubmissionView = nil
        ideaSubmissionView?.unsubscribeToNotifications(self)
    }
    
    /** Load an existing idea from core data if it exists
     *
     *  @param None
     *  @return None
     */
    func loadExistingDataIfExists() {
        ideaSubmissionView?.startLoading()
        findExistingIdea().then() {
            idea -> () in
            if idea != nil {
                self.ideaSubmissionView?.didFindExistingData(self, ideaSubmission: idea!)
            } else {
                self.ideaSubmissionView?.isNewSubmission(self)
            }
        }
    }
    
    /** Find an existing Idea that the user has submitted
     *
     *  @param None
     *  @return Promise<ProjectIdeaSubmission?> -  An optional idea submission record.
     */
    private func findExistingIdea() -> Promise<ProjectIdeaSubmission?> {
        return Promise{resolve, reject in
            do {
                let ideaFetch = NSFetchRequest(entityName: "ProjectIdeaSubmission")
                var idea: ProjectIdeaSubmission? = nil
                if let results = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(ideaFetch) as? [ProjectIdeaSubmission] {
                    guard results.count > 0 else {
                        resolve(nil)
                        return
                    }
                    idea = results[0]
                }
                resolve(idea)
            } catch let error as NSError {
                reject(error)
            }
        }
    }
    
    /** Update one idea to the API.
     *
     *  @param projectIdea: ProjectIdeaSubmission - Core data model for the submission
     *  @return - None
     */
    func updateIdeaToAPI(projectIdea: ProjectIdeaSubmission) {
        projectIdeaService.updateOneIdea(projectIdea).then() {projectIdeaSubmission in
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: true, didFail: nil)
        }.error {error in
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: false, didFail: error as NSError)
        }
    }
    
    /** Submit an idea to the API
     *
     *  @param title: String - the title of the idea (Organization Name)
     *  @param description: String - A textual description of the idea.
     *  @param additionalInformation: String - An optional description or whatever of the idea
     *  @param currentEvent: NextEvent - the event that the idea will be submitted for. Usually will be the next / upcoming event
     *  @return None
     */
    func submitIdeaToAPI(title: String, description: String, additionalInformation: String?, currentEvent: NextEvent) {
        ideaSubmissionView?.startLoading()
        
        let ideaSubmission = createIdeaSubmission(title, description: description, additionalInformation: additionalInformation, eventId: currentEvent.idString)
        
        projectIdeaService.submitIdea(ideaSubmission).then() {Void in
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: true, didFail: nil)
        }.error {error in
            self.ideaSubmissionView?.didSubmitIdeaToAPI(self, didSucceed: false, didFail: error as NSError)
        }
    }
    
    /** Create the model for the idea submission.
     *
     *  @param title: String - the title of the idea (Usually will be the organization's name)
     *  @param description: String - a textual description of the idea to be submitted
     *  @param additionalInformation - An optional string holding additional information for the submission
     *  @return ProjectIdeaSubmissionJSON - An object that can be posted to the API.
     */
    private func createIdeaSubmission(title: String, description: String, additionalInformation: String?, eventId: String) -> ProjectIdeaSubmissionJSON {
        let idea = dictionaryForIdea(title, description: description, additionalInformation: additionalInformation)
        let submission: JsonDict = [
            "user" : UserService.sharedInstance().userId!,
            "event" : eventId,
            "idea" : idea
        ]
        let ideaSubmission = ProjectIdeaSubmission(dictionary: submission, context: GlobalStackManager.SharedManager.sharedContext)
        let ideaSubmissionJSON = ProjectIdeaSubmissionJSON(projectIdeaSubmission: ideaSubmission)
        return ideaSubmissionJSON
    }
    
    /** Dictionary for Idea - Returns a dictionary to be turned into JSON
     *
     *  @param title: String - the title for the idea
     *  @param description: String - a textual description of the idea
     *  @param additionalInformation - an optional string containing additional information for the idea
     *  @return JsonDict - A dictionary [String : AnyObject] containing the data
     */
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
