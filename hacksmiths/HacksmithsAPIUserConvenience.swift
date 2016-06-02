//
//  HacksmithsAPIConvenience.swift
//  hacksmiths
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit

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
    
    /** Clear the member list from Core Data before fetching
     *
     *  @param None
     *  @return Promise of Void (no type) - A Promise that we have deleted the member list.
     */
    private func deleteMemberList() -> Promise<Void> {
        return Promise{resolve, reject in
            resolve()
            /** Note: having some issues with core data in saving the community when a member is deleted from API
             *  I would like to handle this more eloquently
             */
//            let fetchRequest = NSFetchRequest(entityName: "Person")
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//            do {
//                try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: GlobalStackManager.SharedManager.sharedContext)
//                resolve()
//            } catch let error as NSError {
//                print("An error occured while deleting all event data")
//                reject(error as NSError)
//            }
        }
    }
    
    /** Get the member list from the API.  This is legacy from implementation before promises and Gloss JSON library.
     *
     *  @param body - an empty object
     *  @param - CompletionHandler - the completion handler with error and success.
     */
    func getMemberList(body: [String :AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.Members
        syncInProgress = true
        
        deleteMemberList().then() {
            Void in
            self.taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
                
                if error != nil {
                    self.syncInProgress = false
                    completionHandler(success: false, error: error)
                } else {
                    
                    if let membersArray = result["members"] as? [[String : AnyObject]] {
                        for member in membersArray {
                            
                            /* Create a person and save the context */
                            let person = Person(dictionary: member, context: GlobalStackManager.SharedManager.sharedContext)
                            
                            /* Fetch the images and then save the context again at the end.  Return an error if there is one. */
                            person.fetchImages({success, error in
                                if error != nil {
                                    completionHandler(success: false, error: error)
                                }
                            })
                            
                            GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                        }
                    }
                    
                    GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                        CoreDataStackManager.sharedInstance().saveContext()
                    })
                    self.syncInProgress = false
                    completionHandler(success: true, error: nil)
                }
            })

            }.error {
                error in
                completionHandler(success: false, error: error as NSError)
            }
    }
 }
