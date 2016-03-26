//
//  HacksmithsAPIConvenience.swift
//  hacksmiths
//S
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
                        UserDefaults.sharedInstance().authenticated = true
                        UserDefaults.sharedInstance().userId = userId
                        UserDefaults.sharedInstance().dateAuthenticated = NSDate()
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
                        UserDefaults.sharedInstance().authenticated = true
                        UserDefaults.sharedInstance().userId = userId
                        let date = NSDate()
                        UserDefaults.sharedInstance().dateAuthenticated = date
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
                                UserDefaults.sharedInstance().authenticated = true
                                UserDefaults.sharedInstance().userId = userId
                                UserDefaults.sharedInstance().dateAuthenticated = NSDate()
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
    
    // Make a request to get user's profile data from the API.
    func getUserDataFromAPI(body: [String: AnyObject], completionHandler: CompletionHandler) {
        let method = HacksmithsAPIClient.Routes.Profile
        
        if UserDefaults.sharedInstance().authenticated {
            
            if let userID = UserDefaults.sharedInstance().userId {
                let params: [String : AnyObject] = [
                    HacksmithsAPIClient.Keys.user : userID
                ]
                HacksmithsAPIClient.sharedInstance().taskForGETMethod(method, parameters: params, completionHandler: {success, result, error in
                    
                    if error != nil {
                        
                        completionHandler(success: false, error: error)
                    
                    } else {
                        
                        if let profileDict = result[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.dictKey] as? [String : AnyObject] {
                            
                            
                            
                            let userDict = self.dictionaryForUserData(profileDict)
                            
                            let userData = UserData(dictionary: userDict, context: self.sharedContext)
                            
                            self.sharedContext.performBlockAndWait({
                                
                                CoreDataStackManager.sharedInstance().saveContext()
                                
                            })
                            
                            completionHandler(success: true, error: nil)
                        
                        } else {
                        
                            completionHandler(success: false, error: Errors.constructError(domain: "Hacksmiths API Client", userMessage: "Sorry, but an error occured while loading data from the network."))
                            
                        }
                    }
                })
            }
        }
        
        completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Please make sure you are authenticated before making that request."))
        
        
    }
    
    func getMemberList(body: [String :AnyObject], completionHandler: CompletionHandler) {
        let method = Routes.Members
        
        syncInProgress = true
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            
            if error != nil {
                self.syncInProgress = false
                completionHandler(success: false, error: error)
                
            } else {
                guard result != nil else {
                    completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Error returned from server.  Please check your connection and try again."))
                    return
                }
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
    
    func checkAPIForEvents(completionHandler: CompletionHandler) {
        let method = Routes.EventStatus
        let body = [String :AnyObject]()
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                if result != nil {
                     
                    if let success = result[HacksmithsAPIClient.JSONResponseKeys.Success] as? Bool, events = result[HacksmithsAPIClient.JSONResponseKeys.Event.events] as? [String:AnyObject] {
                        
                        if success != true {
                            
                            
                            completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Error while connecting to the networked API.  Please make sure you are logged in and try again."))
                            
                            
                        } else {
                            
                            /* Check that the last and next event exist and then parse and save */
                            let lastEvent = events["last"]
                            let nextEvent = events["next"]
                            
                            /* Check to see that we don't get false or nil */
                            if lastEvent != nil || false {
                                
                                /* Force cast to [String : AnyObject] since logic above protects against bad data */
                                let lastEventDictionary = lastEvent as! [String : AnyObject]
                                /* Create an event with dictionary */
                                let event = Event(dictionary: self.dictionaryForEvent(lastEventDictionary), context: self.sharedContext)
                                
                            }
                            
                            if nextEvent != nil || false {
                                let nextEventDictionary = nextEvent as! [String: AnyObject]
                                
                                let next = Event(dictionary: self.dictionaryForEvent(nextEventDictionary), context: self.sharedContext)
                            }
                            
                            /*  Save our new events */
                            self.sharedContext.performBlockAndWait( {
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                            
                        }
                        
                    }
                    
                }
                    
            }
            
         })
        
    }
    
    func dictionaryForUserData(user: [String : AnyObject]) -> [String : AnyObject] {
        let dictionary: [String : AnyObject] = [
            "name" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.name]!,
            "bio" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio]!,
            "photo" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.photo]!,
            "website" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.website]!,
            "email" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.email]!,
            "isPublic" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isPublic]!,
            "totalHatTips" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.totalHatTips]!,
            "rank" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.rank]!,
            "notications" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.notifications]!,
            "mentoring" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.dictionaryKey]!,
            "availability" : user[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.dictKey]!,
            
        ]
        return dictionary
    }
    
    /* Takes an event dictionary and returns a dictionary for creating an event */
    func dictionaryForEvent (event: [String : AnyObject]) -> [String : AnyObject]{
        let dictionary: [String : AnyObject] = [
            "id" : event[HacksmithsAPIClient.JSONResponseKeys.Event.id]!,
            "title" : event[HacksmithsAPIClient.JSONResponseKeys.Event.title]!,
            "description" : event[HacksmithsAPIClient.JSONResponseKeys.Event.description]!,
            "startDate" : event[HacksmithsAPIClient.JSONResponseKeys.Event.starts]!,
            "endDate" : event[HacksmithsAPIClient.JSONResponseKeys.Event.ends]!
        ]
        return dictionary
    }
}
