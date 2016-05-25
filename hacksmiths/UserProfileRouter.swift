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
    case GetProfile()
    case UpdateProfile(userJSON: UserJSONObject)
}

class UserProfileRouter: BaseRouter {
    var endpoint: ProfileEndpoint
    
    init(endpoint: ProfileEndpoint) {
        self.endpoint = endpoint
    }
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetProfile: return .GET
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
        case .UpdateProfile(let userJSON):
            if let json = userJSON.toJSON() as! JSON {
                return json
            } else {
                return nil
            }
        }
    }
}
