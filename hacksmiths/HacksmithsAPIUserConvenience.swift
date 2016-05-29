//
//  HacksmithsAPIConvenience.swift
//  hacksmiths
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

extension HacksmithsAPIClient {
    
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
                            message = "Unable to register due to unknown reasons.  Please try again."
                        }
                        completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: message!))
                    
                    }
                }
            }
        })
    }
    
    func registerWithEmail(body: [String : AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.SignupEmail
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {success, result, error in
            if error != nil {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                if let success = result["success"] as? Int, session = result["session"] as? Int {
                    if success ==  1 && session == 1 {
                        
                        let userId = result[JSONResponseKeys.Auth.userId] as! String
                        UserService.sharedInstance().authenticated = true
                        UserService.sharedInstance().userId = userId
                        let date = NSDate()
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
    
    
    func getMemberList(body: [String :AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.Members
        
        syncInProgress = true
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            
            if error != nil {
                self.syncInProgress = false
                completionHandler(success: false, error: error)
                
            } else {
                
                if let membersArray = result["members"] as? [[String : AnyObject]] {
                    for member in membersArray {
                        
                        /* Create a person and save the context */
                        let person = Person(dictionary: member, context: self.sharedContext)
                        
                        self.sharedContext.performBlockAndWait({
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        
                        /* Fetch the images and then save the context again at the end.  Return an error if there is one. */
                        person.fetchImages({success, error in
                            if error != nil {
                                completionHandler(success: false, error: error)
                            }
                        })
                    }
                }

                self.sharedContext.performBlockAndWait({
                    CoreDataStackManager.sharedInstance().saveContext()
                })
                self.syncInProgress = false
                completionHandler(success: true, error: nil)
                
            }
            
        })
    }
 
 }
