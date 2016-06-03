//
//  ProjectIdeaRouter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire

enum ProjectIdeaEndpoint {
    case PostProjectIdea(projectIdeaSubmissionJSON: ProjectIdeaSubmissionJSON)
    case GetAllProjectIdeas()
    case DeleteProjectIdea(ideaId: String)
    case UpdateProjectIdea(ideaId: String, ideaJSON: ProjectIdeaSubmissionJSON)
    case GetOneProjectIdea(ideaId: String)
}

/** Handle API routing for the project idea endpoint
 *  taking care of submission of project ideas and also
 *  Will take care of voting for submissions in the next version.
 *
 *  Inherits from the BaseRouter class and implements the AlamoFire Networking API.
 */
class ProjectIdeaRouter: BaseRouter {
    var endpoint: ProjectIdeaEndpoint
    
    init(endpoint: ProjectIdeaEndpoint) {
        self.endpoint = endpoint
    }
    
    /** The HTTP Method to use for the request
     */
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetAllProjectIdeas: return .GET
        case .GetOneProjectIdea: return .GET
        case .PostProjectIdea: return .POST
        case .UpdateProjectIdea: return .PATCH
        case .DeleteProjectIdea: return .DELETE
        }
    }
    
    /** The Path to use for the endpoint
     */
    override var path: String {
        switch endpoint {
        case .GetAllProjectIdeas: return "/api/app/project-ideas"
        case .GetOneProjectIdea(let ideaId): return "api/app/project-ideas/\(ideaId)"
        case .UpdateProjectIdea(let ideaId): return "api/app/project-ideas/\(ideaId)"
        case .PostProjectIdea: return "api/app/project-ideas"
        case .DeleteProjectIdea(let ideaId): return "api/app/project-ideas/\(ideaId)"
        }
    }
    
    /** Parameters to be sent to the API
     */
    override var parameters: JsonDict? {
        switch endpoint {
        case .UpdateProjectIdea( _,let ideaJSON):
            if let ideaJSONDict = ideaJSON.toJSON() {
                return ideaJSONDict
            } else {
                return nil
            }
        case .PostProjectIdea(let projectIdeaSubmissionJSON):
            if let data = projectIdeaSubmissionJSON.toJSON() {
                print("Submitting project idea to API: \(data)")
                return data
            } else {
                return nil
            }
        default: return nil
        }
        
    }
    
    /** Encoding for the parameters.  In this case, only JSON (no URL) parameters.
     */
    override var encoding: ParameterEncoding? {
        switch endpoint {
            default: return .JSON
        }
    }
    
}
