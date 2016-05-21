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
    
    func submitIdea(projectIdeaJSON: ProjectIdeaJSON, userId: String) -> Promise<ProjectIdea?> {
        
        return Promise { fullfill, reject in
            let router = ProjectIdeaRouter(endpoint: .PostProjectIdea(projectIdea: projectIdeaJSON, userId: userId))
            manager.request(router)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        
                        /* Create the idea locally once the server responds with a proper success result */
                        let idea = ProjectIdea()
                        
                        
                    case .Failure(let error):
                        
                        reject(error)
                    }
            }
        }
    }
    
    func getAllIdeas(forEvent: Event) -> Promise<[ProjectIdea]?> {
        
    }
    
    func getOneIdea(ideaId: String) -> Promise<ProjectIdea> {
        
    }
    
    func updateOneIdea(ideaId: String, ideaJSON: IdeaJSON) -> Promise<ProjectIdea> {
        
    }
    
    func deleteOneIdea(ideaId: String, ideaJSON: IdeaJSON) -> Promise<ProjectIdea> {
        
    }

}
