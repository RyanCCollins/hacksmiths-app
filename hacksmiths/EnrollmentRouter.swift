//
//  EnrollmentRouter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire

enum EnrollmentEndpoint {
    case GetAllNanodegrees()
    case GetOneNanodegree(id: String)
}

/** Enrollment router - Not used in v1, but left here for next version
 *  Will take care of loading a person's Udacity Enrollments from the server
 *  So that we can do a better job of matching people based on interests and skill level.
 */
class EnrollmentRouter: BaseRouter {
    var endpoint: EnrollmentEndpoint
    
    init(endpoint: EnrollmentEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetAllNanodegrees():
            return .GET
        case .GetOneNanodegree:
            return .GET
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetAllNanodegrees:
            return "api/app/nanodegrees"
        case .GetOneNanodegree(let id):
            return "api/app/nanodegrees\(id)"
        }
    }
    
    override var encoding: ParameterEncoding? {
        return .URL
    }
    
    override var parameters: JsonDict? {
        switch endpoint {
        default:
            return nil
        }
    }

}
