//
//  UserProfileRouter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss
import Alamofire

enum ProfileEndpoint {
    case GetProfile(userId: String)
    case UpdateProfile(userJSON: UserJSONObject)
}

class UserProfileRouter: BaseRouter {
    var endpoint: ProfileEndpoint
    
    init(endpoint: ProfileEndpoint) {
        self.endpoint = endpoint
    }
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetProfile: return .POST
        case .UpdateProfile: return .POST
        }
    }
    override var path: String {
        switch endpoint {
        case .GetProfile:
            return "api/me/profile"
        case .UpdateProfile:
            return "api/me/profile/update"
        }
    }
    
    override var encoding: ParameterEncoding? {
        return .JSON
    }
    
    override var parameters: JSON? {
        switch endpoint {
        case .GetProfile(let userID):
            let user = ["user" : userID]
            return user
        case .UpdateProfile(let userJSON):
            let json = userJSON.toJSON()
            return json
        default:
            return nil
        }
    }
}
