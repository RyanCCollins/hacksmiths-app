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
                        /* Reset and save the idea, only when there is a success */
                        GlobalStackManager.SharedManager.sharedContext.reset()
                        let ideaSubmission = ProjectIdeaSubmission(ideaSubmissionJson: projectIdeaSubmissionJSON, context: GlobalStackManager.SharedManager.sharedContext)
                        
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

    
    func updateOneIdea(ideaSubmission: ProjectIdeaSubmission) -> Promise<ProjectIdea?> {
        return Promise { resolve, reject in
            resolve(nil)
        }
    }
    
    func deleteOneIdea(ideaId: String, ideaJSON: IdeaJSON) -> Promise<ProjectIdea?> {
        return Promise{resolve, reject in
            resolve(nil)
        }
    }

}
