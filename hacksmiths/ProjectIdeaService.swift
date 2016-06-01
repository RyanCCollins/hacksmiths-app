//
//  ProjectIdeaService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import Gloss

struct Response {
    let error: NSError?
    let success: Bool
}

class ProjectIdeaService {
    let manager = Manager.sharedInstance
    
    /** Submit an idea for a project to the API
     *
     *  @param projectIdeaSubmissionJSON: ProjectIdeaSubmissionJSON - the JSON to be submitted to the API for the Idea
     *  @return Promise<ProjectIdeaSubmission?> - A promise of an optional idea submission, core data model.
     */
    func submitIdea(projectIdeaSubmissionJSON: ProjectIdeaSubmissionJSON) -> Promise<ProjectIdeaSubmission?> {
        return Promise { resolve, reject in
            print("Submitting idea request to API: \(projectIdeaSubmissionJSON)")
            let router = ProjectIdeaRouter(endpoint: .PostProjectIdea(projectIdeaSubmissionJSON: projectIdeaSubmissionJSON))
            manager.request(router)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        let success = JSON["success"] as! Bool
                        
                        if success {
                            guard let idString = JSON["id"] as? String else {
                                reject(GlobalErrors.GenericNetworkError)
                                return
                            }
                            /* Reset and save the idea, only when there is a success */
                            GlobalStackManager.SharedManager.sharedContext.reset()
                            let ideaSubmission = ProjectIdeaSubmission(ideaSubmissionJson: projectIdeaSubmissionJSON, idString: idString, context: GlobalStackManager.SharedManager.sharedContext)
                            
                            GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                            
                            resolve(ideaSubmission)
                        } else {
                            reject(GlobalErrors.GenericNetworkError)
                        }
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    /** Get all of the Ideas for a given event from the API. To be used in v2 when we hold votes for ideas.
     *
     *  @param Event: Event the event that is the current, or a past event.
     *  @return Promise<[ProjectIdea]?> - An array of project ideas for the current event.
     */
    func getAllIdeas(forEvent: Event) -> Promise<[ProjectIdea]?> {
        return Promise { resolve, reject in
            let router = ProjectIdeaRouter.init(endpoint: .GetAllProjectIdeas())
            manager.request(router)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        let projectIdeaArray = JSON["ideas"] as! [JsonDict]
                        let ideas = projectIdeaArray.map({ idea in
                            return ProjectIdeaJSON(json: idea)
                        })
                        
                        let returnArray = ideas.map({idea in
                            return ProjectIdea(ideaJSON: idea!, context: GlobalStackManager.SharedManager.sharedContext)
                        })
                        
                        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        resolve(returnArray)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    /** Get one idea from the API by ID
     *
     *  @param ideaId: String - the id of the Idea to get
     *  @return Promise<ProjectIdea> a Promise of the core data model for Ideas
     */
    func getOneIdea(ideaId: String) -> Promise<ProjectIdea> {
        return Promise {resolve, reject in
            let router = ProjectIdeaRouter.init(endpoint: .GetOneProjectIdea(ideaId: ideaId))
            manager.request(router)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        let JSONData = JSON["idea"] as! JsonDict
                        let projectIdeaJSON = ProjectIdeaJSON(json: JSONData)
                        
                        let projectIdea = ProjectIdea(ideaJSON: projectIdeaJSON!, context: GlobalStackManager.SharedManager.sharedContext)
                        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        
                        resolve(projectIdea)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    /** Update one idea on the API
     *
     *  @param ideaSubmission: ProjectIdeaSubmission - the idea submission core data model.
     *  @return Promise<ProjectIdea?> - A promise of a project idea model
     */
    func updateOneIdea(ideaSubmission: ProjectIdeaSubmission) -> Promise<ProjectIdeaSubmission?> {
        return Promise { resolve, reject in
            let ideaJSON = ProjectIdeaSubmissionJSON(projectIdeaSubmission: ideaSubmission)
            let router = ProjectIdeaRouter.init(endpoint: .UpdateProjectIdea(ideaId: "333", ideaJSON: ideaJSON))
            manager.request(router)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        /** Save the submitted idea to core data.
                         */
                        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        resolve(ideaSubmission)
                        
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    /** Delete one idea on the API.  Currently not being used, but is here for completeness sake for when the idea voting 
     *  is implemented in v2
     *
     *  @param ideaId: String - the Id of the idea on the server
     *  @param ideaJSON: IdeaJSON - the
     *  @return
     */
    func deleteOneIdea(ideaId: String) -> Promise<Bool?> {
        return Promise{resolve, reject in
            let router = ProjectIdeaRouter.init(endpoint: .DeleteProjectIdea(ideaId: ideaId))
            manager.request(router)
                .validate()
                .responseJSON{
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        /* Let success equal true and resolve with false if not */
                        guard let success = JSON["success"] as? Bool where success == true else {
                            resolve(false)
                            return
                        }
                        /* Resolve with true, meaning all is well and the idea has been deleted */
                        resolve(true)
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }

}
