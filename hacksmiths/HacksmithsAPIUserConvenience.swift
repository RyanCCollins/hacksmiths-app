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
    
    // Make a request to get user's profile data from the API.
    func getUserDataFromAPI(body: [String: AnyObject], completionHandler: CompletionHandler) {
        let method = HacksmithsAPIClient.Routes.Profile
        
        if UserService.sharedInstance().authenticated {
            
            if let userID = UserService.sharedInstance().userId {
                let params: [String : AnyObject] = [
                    HacksmithsAPIClient.Keys.user : userID
                ]
                HacksmithsAPIClient.sharedInstance().taskForPOSTMethod(method, JSONBody: params, completionHandler: {success, result, error in
                    
                    if error != nil {
                        
                        completionHandler(success: false, error: error)
                    
                    } else {
                        
                        guard result != nil else {
                            
                            completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Error downloading data to the network.  Please try again."))
                            return
                        }
                        
                        if let success = result["success"] as? Bool {
                            if let profileDict = result[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.dictKey] as? [String : AnyObject] {
                                
//                                let userDict = self.dictionaryForUserData(profileDict)
//                                let userData = UserData(dictionary: userDict, context: self.sharedContext)
//                        
//                                self.sharedContext.performBlockAndWait({
//                                    CoreDataStackManager.sharedInstance().saveContext()
//                                })
//                                
                                completionHandler(success: true, error: nil)
                                
                            } else {
                                completionHandler(success: false, error: Errors.constructError(domain: "Hacksmiths API Client", userMessage: "Sorry, but an error occured while loading data from the network."))
                            }
                        } else {
                            completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
                        }
                    }
                })
            }
        }
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
 
    
    // Unwrap all the data returned from the API, assuring that we have good data.all
    // This is starting to get out of hand, so we should likely setup the server to only return good data.
    func dictionaryForUserData(user: [String : AnyObject]) -> [String : AnyObject] {
        var fullName = "", bioText = "", email = "", isPublic = false, isAvailableAsAMentor = false,
        needsAMentor = false, rank: NSNumber = 0, website = "", mobileNotifications = false,
        totalHatTips: NSNumber = 0, isTopContributor = false, hasExperience = "", wantsExperience = "",
        isAvailableForEvents = false, availabilityExplanation = ""
        
        if let name = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.name] as? JsonDict {
            let firstName = name["first"] as? String
            let lastName = name["last"] as? String
            fullName = "\(firstName!) \(lastName!)"
        }
        
        if let topContributor = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.isTopContributor] as? Bool {
            isTopContributor = topContributor
        }
        
        
        if let bio = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio] as? JsonDict {
            if let bioMD = bio[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bioMD] as? String {
                bioText = bioMD
            }
        }
        
        if let userWebsite = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.website] as? String {
            website = userWebsite
        }
        
        if let userEmail = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.email] as? String {
            email = userEmail
        }
        
        if let publicStatus = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isPublic] as? Bool {
            isPublic = publicStatus
        }
        
        if let hatTips = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.totalHatTips] as? NSNumber {
            totalHatTips = hatTips
        }
        
        if let availabilityDict = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.dictKey] as? JsonDict {
            isAvailableForEvents = availabilityDict[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.availability.isAvailableForEvents] as! Bool
            if let explanation = availabilityDict[HacksmithsAPIClient.JSONResponseKeys.MemberData.EventInvolvement.availability.explanation] as? String {
                availabilityExplanation = explanation
            }
        }
        
        if let notifications = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.notifications] as? JsonDict {
            mobileNotifications = notifications[HacksmithsAPIClient.JSONResponseKeys.MemberData.Notifications.mobile] as! Bool
        }
        
        if let mentoringDictionary = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.dictionaryKey] {
            isAvailableAsAMentor = mentoringDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.available] as! Bool
            needsAMentor = mentoringDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.needsAMentor] as! Bool
            
            if let skillExplanation = mentoringDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.experience] as? String {
                hasExperience = skillExplanation
            }
            
            if let skillsWanted = mentoringDictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.mentoring.want] as? String {
                wantsExperience = skillsWanted
            }
        }
        
        if let userRank = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.rank] as? NSNumber {
            rank = userRank
        }
        
        let updatedAt = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.updatedAt] as! String
        
        var dictionary: [String : AnyObject] = [
            "name" : fullName,
            "bio" : bioText,
            "website" : website,
            "email" : email,
            "isPublic" : isPublic,
            "rank" : rank,
            "mobile" : mobileNotifications,
            "available": isAvailableAsAMentor,
            "needsAMentor" : needsAMentor,
            "experience": hasExperience,
            "wantsExperience": wantsExperience,
            "updatedAt": updatedAt,
            "totalHatTips": totalHatTips,
            "isTopContributor": isTopContributor,
            "isAvailableForEvents" : isAvailableForEvents,
            "explanation": availabilityExplanation
        ]
        
        //Photo can be nil, so we need to protect against that
        if let photo = user[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.photo] {
            dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.photo] = photo
        }
        

        return dictionary
    }
}
