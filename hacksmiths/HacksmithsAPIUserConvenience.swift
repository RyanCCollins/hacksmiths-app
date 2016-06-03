//
//  HacksmithsAPIConvenience.swift
//  hacksmiths
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit

/** Extension for the API Client for user / member taskForPOSTMethod
 *  This is leftover from the refactor to utilizing seperate services with Alamo
 *  And eventually will be refactored to be more elegant, but is working fine now.
 */
extension HacksmithsAPIClient {
    
    /** Check the service (API) to ensure that all is well.
     *
     *  @param body - A body to submit to the API
     *  @param completionHandler - the completion handler to use when the task is complete.
     *  @return None
     */
    func checkService(body: [String : AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.SigninServiceCheck
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {sucess, result, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                if let success = result["success"] as? Int, session = result["session"] as? Int {
                    if success ==  1 && session == 1 {
                        
                        let userId = result[JSONResponseKeys.Auth.userId] as! String
                        UserService.sharedInstance().authenticated = true
                        UserService.sharedInstance().userId = userId
                        UserService.sharedInstance().dateAuthenticated = NSDate()
                        completionHandler(success: true, error: nil)
                        
                    } else {
                        
                        var message = result[JSONResponseKeys.Auth.message] as? String
                        
                        if message == nil {
                            message = "An unknown error occured while checking the API.  Please try again."
                        }
                        completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: message!))
                    }
                }
            }
        })
    }
    
    /** Register for an account with an email address.
     *
     *  @param registrationJSON - a JSON object for registration
     *  @param completionHandler - the completion handler to run when request has finished
     *  @return None
     */
    func registerWithEmail(registrationJSON: RegistrationJSON, completionHandler: CompletionHandler) {
        let method = Routes.SignupEmail
        let body = registrationJSON.toJSON()
        taskForPOSTMethod(method, JSONBody: body!, completionHandler: {success, result, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                
                if let success = result["success"] as? Int, session = result["session"] as? Int {
                    if success ==  1 && session == 1 {
                        
                        let userId = result[JSONResponseKeys.Auth.userId] as! String
                        UserService.sharedInstance().authenticated = true
                        
                        UserService.sharedInstance().userId = userId
                        let date = NSDate()
                        UserService.sharedInstance().authToken = result["authToken"] as? String
                        UserService.sharedInstance().dateAuthenticated = date
                        completionHandler(success: true, error: nil)
                        
                    } else {
                        
                        var message = result[JSONResponseKeys.Auth.message] as? String
                        
                        if message == nil {
                            message = "Unable to register due to unknown reasons.  Please try again."
                        }
                        completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: message!))
                    }
                }
            }
        })
    }
    
    /** Authenticate with the API, creating a session and storing to NSUserDefaults
     *
     *  @param username: String The username used to sign in
     *  @param password: String - the password used to sign in
     *  @param completionHandler - A block to run on completion of the request.
     *  @return None
     */
    func authenticateWithCredentials(username: String, password: String, completionHandler: CompletionHandler) {
        let method = Routes.SigninEmail
        let body = [Keys.Username: username, Keys.Password: password]
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {success, result, error in
            if error != nil {
                self.syncInProgress = false
                completionHandler(success: false, error: error)
                
            } else {
                /* If we receive a successful response and the server responds with success == true, carry on parsing the data */
                if let success = result[JSONResponseKeys.Auth.success] as? Bool {
                    if success == false {
                        completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Sorry, but we were unable to sign you in.  Please check your password and try again."))
                    } else {
                        if let success = result["success"] as? Int, session = result["session"] as? Int {
                            if success ==  1 && session == 1 {
                                
                                let userId = result[JSONResponseKeys.Auth.userId] as! String
                                UserService.sharedInstance().authenticated = true
                                UserService.sharedInstance().userId = userId
                                UserService.sharedInstance().authToken = result["authToken"] as? String
                                UserService.sharedInstance().dateAuthenticated = NSDate()
                                completionHandler(success: true, error: nil)
                                
                            } else {
                                
                                var message = result[JSONResponseKeys.Auth.message] as? String
                                
                                if message == nil {
                                    message = "Unable to login due to unknown reasons.  Please try again."
                                }
                                completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: message!))
                            }
                        }
                    }
                }
            }
        })
    }
 }
