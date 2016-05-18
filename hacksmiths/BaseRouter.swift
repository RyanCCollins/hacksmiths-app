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
    var parameters: String { get }
}


class Router: URLRequestConvertible {
    public static var baseURL: String {
        var configuration: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("APIKeys", ofType: "plist") {
            configuration = NSDictionary(contentsOfFile: path)
            return configuration["HACKSMITHS_BASE_URL"] as? String ?? ""
        }
    }
    
    public var URLRequest: NSMutableURLRequest {
        let baseAPIURL = NSURL(string: baseURL)
        let mutableURLRequest = NSMutableURLRequest(URL: baseAPIURL)
        mutableURLRequest.HTTPMethod = method.rawValue
        if let encoding = encoding {
            return encoding.encode(mutableURLRequest, parameters: parameters).0
        }
        return mutableURLRequest
    }
    
}
