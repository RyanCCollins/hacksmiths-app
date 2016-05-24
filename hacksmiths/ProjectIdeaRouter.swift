//
//  ProjectIdeaRouter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire
import Gloss


enum ProjectIdeaEndpoint {
    case PostProjectIdea(projectIdeaSubmissionJSON: ProjectIdeaSubmissionJSON)
    case GetAllProjectIdeas()
    case DeleteProjectIdea(ideaId: String)
    case UpdateProjectIdea(ideaId: String, ideaJSON: ProjectIdeaJSON)
    case GetOneProjectIdea(ideaId: String)
}

class ProjectIdeaRouter: BaseRouter {
    var endpoint: ProjectIdeaEndpoint
    init(endpoint: ProjectIdeaEndpoint) {
        self.endpoint = endpoint
    }
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetAllProjectIdeas: return .GET
        case .GetOneProjectIdea: return .GET
        case .PostProjectIdea: return .POST
        case .UpdateProjectIdea: return .PATCH
        case .DeleteProjectIdea: return .DELETE
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetAllProjectIdeas: return "/api/app/project-ideas"
        case .GetOneProjectIdea(let ideaId): return "api/app/project-ideas/\(ideaId)"
        case .UpdateProjectIdea(let ideaId, let projectIdeaJSON): return "api/app/project-ideas/\(ideaId)"
        case .PostProjectIdea(let projectIdeaJson): return "api/app/project-idea"
        case .DeleteProjectIdea(let ideaId): return "api/app/project-ideas/\(ideaId)"
        }
    }
    
    override var parameters: JsonDict? {
        switch endpoint {
        case .UpdateProjectIdea(let ideaId, let ideaJSON):
            if let ideaJSONDict = ideaJSON.toJSON() {
                return ideaJSONDict
            } else {
                return nil
            }
        case .PostProjectIdea(let projectIdeaJSON):
            if let data = projectIdeaJSON.toJSON() {
                return data
            } else {
                return nil
            }
        default: return nil
        }
        
    }
    
    override var encoding: ParameterEncoding? {
        switch endpoint {
            default: return .JSON
        }
    }
    
}
