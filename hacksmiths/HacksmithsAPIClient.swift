//
//  HacksmithsAPIClient.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class HacksmithsAPIClient: NSObject {
    var syncInProgress: Bool = false
    
    /* The HacksmithsAPIClient class totally abstracts away all logic for connecting to the HACKSMITHS API for the purposes of
    *  downloading data
    *  NOTE: At an earlier point in time, this file was used for mose API calls.  That got messy fast, so I implemented a much more elegant solution
    *  Using alamofire, Gloss for JSON parsing, etc.  All of this is totally abstracted out into various model classes and structs throughout the project.
    */
    
    /* Task returned for GETting data from the server */
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, completionHandler: CompletionHandlerWithResult) -> NSURLSessionDataTask {
        var urlString = Constants.APIURL + method
        /* If our request includes parameters, add those parameters to our URL */
        if parameters != nil {
            if let parameters = parameters {
                urlString += HacksmithsAPIClient.stringByEscapingParameters(parameters)
            }
        }
        
        let url = NSURL(string: urlString)!
        print(">>> Making API Request with url: \(url)")
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPRequest.GET
        
        /*Create a session and then a task */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, result: nil, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: ErrorMessages.Status.Network))
            } else {
                /* GUARD: Did we get a successful response code of 2XX? */
                self.guardForHTTPResponses(response as? NSHTTPURLResponse) {proceed, error in
                    if error != nil {
                        print(response)
                        completionHandler(success: false, result: nil, error: error)
                        
                    }
                }
                
                guard data != nil else {
                    completionHandler(success: false, result: nil, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: ErrorMessages.Status.Network))
                    return
                }
                
                /* Parse the results and return in the completion handler with an error if there is one. */
                HacksmithsAPIClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)

            }
        }
        task.resume()
        return task
    }
    
    /* Abtraction that returns a UIImage from a URL from HacksmithsAPIClient
    Making our life a bit easier for photo processing */
    func taskForGETImageFromURL(url: String, completionHandler: CompletionHandlerWithImage) -> NSURLSessionDataTask {
        let url = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = HTTPRequest.GET
        
        /*Create a session and then a task */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                print(error)
                completionHandler(image: nil, error: Errors.constructError(domain: "HacksmithsAPI", userMessage: ErrorMessages.Status.Network))
                
            } else {
                /* GUARD: Did we get a successful response code of 2XX? and return error if not found */
                self.guardForHTTPResponses(response as? NSHTTPURLResponse) {proceed, error in
                    if error != nil {
                        completionHandler(image: nil, error: error!)
                    }
                }
                
                /* Here we are simply creating an image and returning it via the completionhandler */
                if let imageData = data {
                    if let imageToReturn = UIImage(data: imageData) {
                        completionHandler(image: imageToReturn, error: nil)
                    }
                    
                } else {
                    /* If we get a network error, return a callback */
                    completionHandler(image: nil, error: Errors.constructError(domain: "HacksmithsAPI", userMessage: "Unable to get an image from Network.  Please try again."))
                    
                }
            }
        }
        
        task.resume()
        return task
    }
    
    /** Handle posting data to the Hacksmiths API.
     *  Was used before refactoring into seperate services and now is used by just a few methods.
     *
     *  @param method - the method t0 call
     *  @return
     */
    func taskForPOSTMethod (method: String, JSONBody: [String : AnyObject], completionHandler: CompletionHandlerWithResult) -> NSURLSessionDataTask {
        let urlString = Constants.APIURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        print(urlString)
        
        request.HTTPMethod = HTTPRequest.POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONBody, options: .PrettyPrinted)
        } catch {
            request.HTTPBody = nil
            completionHandler(success: false, result: nil, error: Errors.constructError(domain: "HacksmithsAPI", userMessage: ErrorMessages.JSONSerialization))
        }
        /* Create a session and then a task.  Parse results if no error. */
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, result: nil, error: Errors.constructError(domain: "HacksmithsAPI", userMessage: ErrorMessages.Status.Network))
            } else {
                /* GUARD: Did we get a successful response code in the realm of 2XX? */
                self.guardForHTTPResponses(response as? NSHTTPURLResponse) {proceed, error in
                    if error != nil {
                        completionHandler(success: false, result: nil, error: error)
                    }
                }
                /* Parse the results and return in the completion handler with an error if there is one. */
                HacksmithsAPIClient.parseJSONDataWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    /* Helper Function: Convert JSON to a Foundation object */
    class func parseJSONDataWithCompletionHandler(data: NSData, completionHandler: CompletionHandlerWithResult) {
        var parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandler(success: false, result: nil, error: Errors.constructError(domain: "HacksmithsAPI", userMessage: ErrorMessages.Parse))
        }
    
        completionHandler(success: true, result: parsedResult, error: nil)
    }
    
    
    /* Helper Function: Given an optional dictionary of parameters and an optional dictionary of query parameters, convert to a URL encoded string */
    class func stringByEscapingParameters(parameters: [String : AnyObject]?) -> String {
        
        var components = [String]()
        
        if parameters != nil {
            components.append(URLString(fromParameters: parameters!, withSeperator: "="))
            
        }
        
        return (!components.isEmpty ? "?" : "") + components.joinWithSeparator("&")
        
    }
    
    /* Helper function builds a parameter or query string based on a dictionary of parameters.  Takes a string as an argument called seperator, which is used as : for parameters and = for queries */
    class func URLString(fromParameters parameters: [String : AnyObject], withSeperator seperator: String) -> String {
        var queryComponents = [(String, String)]()
        
        for (key, value) in parameters {
            queryComponents += recursiveURLComponents(key, value)
        }
        
        return (queryComponents.map {"\($0)\(seperator)\($1)" } as [String]).joinWithSeparator("&")
        
    }
    
    /*
    The following three functions are a mashup of several ideas that I recreated in order to query REST APIs.
    This function recursively constructs a query string from parameters:
    Takes a key from a dictionary as a String and its related parameters of AnyObject and traverses through
    the parameters, building an array of String tuples containing the key value pairs
    This is used to construct components for complex queries and parameter calls that are more than just String : String.
    The parameter object can be a dictionary, array or string.
    */
    class func recursiveURLComponents(keyString : String, _ parameters: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let parameterDict = parameters as? [String : AnyObject] {
            for (key, value) in parameterDict {
                components += recursiveURLComponents("\(keyString)[\(key)]", value)
            }
        } else if let parameterArray = parameters as? [AnyObject] {
            for parameter in parameterArray {
                components += recursiveURLComponents("\(keyString)[]", parameter)
            }
            
        } else {
            components.append((escapedString(keyString), escapedString("\(parameters)")))
        }
        return components
    }
    
    /* Helper function, takes a string as an argument and returns an escaped version of it to be sent in an HTTP Request */
    class func escapedString(string: String) -> String {
        let escapedString = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return escapedString!
    }
    
    /* Singleton shared instance of HacksmithsAPI */
    class func sharedInstance() -> HacksmithsAPIClient {
        struct Singleton {
            static var sharedInstance = HacksmithsAPIClient()
        }
        return Singleton.sharedInstance
    }
    
    /* Abstraction of repetive guard statements in each request function */
    func guardForHTTPResponses(response: NSHTTPURLResponse?, completionHandler: (proceed: Bool, error: NSError?) -> Void) -> Void {
        /* GUARD: Did we get a successful response code of 2XX? */
        guard let statusCode = response?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            var statusError: NSError?
            
            /* If not, what was our status code?  Provide appropriate error message and return */
            if let response = response {
                if response.statusCode >= 400 && response.statusCode <= 599 {
                    statusError = Errors.constructError(domain: "FlickrClient", userMessage: ErrorMessages.Status.Auth)
                }
            } else {
                statusError = Errors.constructError(domain: "FlickrClient", userMessage: ErrorMessages.Status.InvalidResponse)
            }
            
            completionHandler(proceed: false, error: statusError)
            return
        }
        completionHandler(proceed: true, error: nil)
    }
    
    /* Our ImageCache singleton struct */
    struct Caches {
        static let imageCache = ImageCache()
    }
}
