//
//  BaseRouter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire
import Foundation

protocol APIConfig {
    var method: Alamofire.Method { get }
    var encoding: Alamofire.ParameterEncoding? { get }
    var path: String { get }
    var parameters: JsonDict? { get }
}


class BaseRouter: URLRequestConvertible, APIConfig {
    
    init() {}

    var method: Alamofire.Method {
        fatalError("[BaseRouter - \(#function)] Must be overridden in subclass")
    }
    
    var encoding: Alamofire.ParameterEncoding? {
        fatalError("[BaseRouter - \(#function)] Must be overridden in subclass")
    }
    
    var path: String {
        fatalError("[BaseRouter - \(#function)] Must be overridden in subclass")
    }
    
    var parameters: JsonDict? {
        fatalError("[BaseRouter - \(#function)] Must be overridden in subclass")
    }
    
    var baseURL: String {
        var configuration: NSDictionary?
        var returnURL: String = ""
        if let path = NSBundle.mainBundle().pathForResource("APIKeys", ofType: "plist") {
            configuration = NSDictionary(contentsOfFile: path)
            returnURL =  configuration!["HACKSMITHS_BASE_URL"] as? String ?? ""
        }
        return returnURL
    }
    
    var URLRequest: NSMutableURLRequest {
        let baseAPIURL = NSURL(string: baseURL)
        let mutableURLRequest = NSMutableURLRequest(URL: baseAPIURL!)
        mutableURLRequest.HTTPMethod = method.rawValue
        if let encoding = encoding {
            return encoding.encode(mutableURLRequest, parameters: parameters).0
        }
        return mutableURLRequest
    }
    
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}

