//
//  ProfileData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/3/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData


protocol ProfileView {
    // TODO: Transfer to Presenter pattern
}

protocol ProfileDataUpdateDelegate {
    func didUpdateUserProfileData(userData: UserData)
}

/* TODO: Refactor into MVP Presenter class */
class ProfileDataFetcher: NSObject {
    static let sharedInstance = ProfileDataFetcher()
    var userData: UserData?
    var requiresFetch = true
    
    // Public interface for fetching and updating data from API
    internal func fetchAndUpdateData(completionHandler: CompletionHandler) {
        // If the user is authenticated then create a request to get the profile data:
        if UserService.sharedInstance().authenticated == true {
            let userID = UserService.sharedInstance().userId
            
            // Protect against the UserID being nil, for some reason
            guard userID != nil || userID != "" else {
                completionHandler(success: false, error: Errors.constructError(domain: "ProfileDataFetcher", userMessage: "An error occured connecting you to the server.  If the problem continues, please log out and log back in."))
                return
            }
            
            let dictionary: [String : AnyObject] = [ "user" : userID! ]
            HacksmithsAPIClient.sharedInstance().getUserDataFromAPI(dictionary, completionHandler: {success, error in
                
                if error != nil {
                    completionHandler(success: false, error: error)
                    
                } else {
                    
                    self.performUserFetch({success, userData, error in
                        if error != nil {
                            self.requiresFetch = true
                            completionHandler(success: false, error: error)
                        } else {
                            self.requiresFetch = false
                            self.userData = userData
                            completionHandler(success: true, error: nil)
                        }
                    })
                }
            })
        }
    }
    
    
    // Update profile data when userData has changed.
    internal func updateProfileData(completionHandler: CompletionHandler) {
        
        if let profileDict = dictForProfileUpdate() {
            HacksmithsAPIClient.sharedInstance().updateProfile(profileDict, completionHandler: {success, error in
                
                if error != nil {
                    completionHandler(success: false, error: error)
                } else {
                    self.requiresFetch = true
                    completionHandler(success: true, error: nil)
                }
                
            })
        } else {
            completionHandler(success: false, error: Errors.constructError(domain: "ProfileData", userMessage: "An unknown error occurred while attempting to update your profile data.  If the problem persists, please try logging out and logging back in."))
        }
    }
    
    private func dictForProfileUpdate() -> JsonDict? {
        if let userProfileData = userData {
            let id = UserService.sharedInstance().userId
            
            guard id != nil else {
                return nil
            }
            
            var returnDict: JsonDict = [
                "id": id!
            ]
            
            if let bio = userProfileData.bio {
                returnDict["bio"] = bio
            }
            
            returnDict["availability"] = buildAvailabilityDict(userProfileData.isAvailableForEvents, availabilityExplanation: userProfileData.availabilityExplanation)
            
            if let website = userProfileData.website {
                returnDict["website"] = website
            }
            
            returnDict["notifications"] = buildNotificationsDict(userProfileData.mobileNotifications)
            
            return returnDict
        }
        
        return nil
    }
    
    private func buildBioDict(bio: String) -> JsonDict {
        let bioDict: JsonDict = [
            "md": bio,
            "html": bio
        ]
        return bioDict
    }
    
    private func buildNotificationsDict(mobileNotifications: Bool) -> JsonDict {
        let notificationsDict: JsonDict = [
            "mobile": mobileNotifications
        ]
        return notificationsDict
    }
    
    private func buildAvailabilityDict(isAvailableForEvents: Bool, availabilityExplanation: String?) -> JsonDict {
        var availabilityDict: JsonDict = [
            "isAvailableForEvents": isAvailableForEvents
        ]
        
        if availabilityExplanation != nil {
            availabilityDict["explanation"] = availabilityExplanation
        }
        
        return availabilityDict
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "dateUpdated", ascending: false)
        let userDataFetch = NSFetchRequest(entityName: "UserData")
        userDataFetch.sortDescriptors = [sortPriority]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: userDataFetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    private func performUserFetch(completionHandlerWithUserData: CompletionHandlerWithUserData) {
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            completionHandlerWithUserData(success: false, userData: nil, error: error)
        }
        
        if let userData = fetchedResultsController.fetchedObjects![0] as? UserData {
            completionHandlerWithUserData(success: true, userData: userData, error: nil)
        } else {
            completionHandlerWithUserData(success: false, userData: nil, error: Errors.constructError(domain: "ProfileData", userMessage: "An error occured while retrieving your user data.  If the error continues, please sign out and sign back in."))
        }
    }
    
}

