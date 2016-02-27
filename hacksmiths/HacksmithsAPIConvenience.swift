//
//  HacksmithsAPIConvenience.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

extension HacksmithsAPIClient {
    
    func checkService() {
        
    }
    
    func registerWithCredentials(username: String, password: String, completionHandler: CompletionHandler) {
        let method = Routes.SignupEmail
        
        let body = [Keys.Username: username, Keys.Password: password]
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {success, result, error in
            if error != nil {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                print(result)
                completionHandler(success: true, error: nil)
            }
        })
    }

    func authenticateWithCredentials(username: String, password: String, completionHandler: CompletionHandler) {
        let method = Routes.SigninEmail
        
        let body = [Keys.Username: username, Keys.Password: password]
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {success, result, error in
            if error != nil {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                /* If we receive a successful response and the server responds with success == true, carry on parsing the data */
                if let success = result[JSONResponseKeys.Auth.success] as? Bool {
                    if success == false {
                    completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Sorry, but we were unable to sign you in.  Please check your password and try again."))
                    } else {
                        let userId = result[JSONResponseKeys.Auth.userId] as! Int
                        let date = result[JSONResponseKeys.Auth.date] as! NSDate
                        
                        UserData.sharedInstance().userId = userId
                        
                        completionHandler(success: true, error: nil)
                    
                    }
                }
                
            }
            
        })
        
    }
    
    func getDataFromAPI(body: [String: AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.EventStatus
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            
            if error != nil {
                print(error)
            } else {
                print(result)
            }
            
        })
    }
    
    func getMemberList(body: [String :AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.Members
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                
                if let membersArray = result[HacksmithsAPIClient.JSONResponseKeys.Members] as? [String : AnyObject] {
                    print(membersArray)
                }
                
            }
            
        })
    }
    
    func checkAPIStatus(body: [String: AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.EventStatus
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                if let status = result[HacksmithsAPIClient.JSONResponseKeys.Status] as? [String : AnyObject] {
                    let success = status["success"] as! Bool
                    if success != true {
                        completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Error while connecting to the networked API.  Please make sure you are logged in and try again."))
                    } else {
                        
                        let events = status["events"] as! [String : AnyObject]
                        
                        
                        
                    }
                }
            }
        })
        
    }
    
}
