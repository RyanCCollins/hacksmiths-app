//
//  UserProfileService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire
import PromiseKit
import Gloss
import CoreData

/** Handle communaction with the API for user Profile interactions
 */
class UserProfileService {
    
    /* Get the profile data for the currently signed in user
     * @params - userId: String - The user's ID Token
     * @return - Promise: UserData,  a promise of user data the core data model
     */
    func getProfile(userId: String) -> Promise<UserData?> {
        return Promise{resolve, reject in
            let router = UserProfileRouter(endpoint: .GetProfile(userId: userId))
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON{
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        if let profileDict = JSON[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.dictKey] as? JsonDict {
                            print("Creating profile with \(profileDict)")
                            let userJSON = UserJSONObject(json: profileDict)
                            
                            let userData = UserData(json: userJSON!, context: GlobalStackManager.SharedManager.sharedContext)
                            
                            GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                            
                            resolve(userData)
                        } else {
                            reject(GlobalErrors.GenericNetworkError)
                        }
                    case .Failure(let error):
                        reject(error as NSError)
                    }
            }
        }
    }
    
    /* - Update the user's profile information
     * - parameters - UserJSONObject containing updated profile information and the user's Id
     * - return - Promise of Void (i.e. resolve or reject with no return value.
     */
    func updateProfile(userJSON: UserJSONObject, userID: String) -> Promise<Void> {
        return Promise{resolve, reject in
            let router = UserProfileRouter(endpoint: .UpdateProfile(userJSON: userJSON))
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON{
                    response in
                    
                    switch response.result {
                    case .Success:
                        resolve()
                    case .Failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    /** Fetch saved user data from core data
     *
     *  @param None
     *  @return Promise<UserData?> - A Promise of the user data managed object
     */
    func fetchSavedUserData() -> Promise<UserData?> {
        return Promise{resolve, reject in
            performUserFetch({success, userData, error in
                if error != nil {
                    reject(error! as NSError)
                } else {
                    resolve(userData)
                }
            })
        }
    }
    
    /** Delete all of the user data records when they are no longer in use.
     *
     *  @param None
     *  @return Promise<Void> - A promise that user data has been deleted
     */
    func deleteUserDataRecords() -> Promise<Void> {
        return Promise{ resolve, reject in
            let fetchRequest = NSFetchRequest(entityName: "UserData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: GlobalStackManager.SharedManager.sharedContext)
                resolve()
            } catch let error as NSError {
                print("An error occured while deleting all event data")
                reject(error)
            }
        }
    }
    
    /** Fetched results controller - used to fetch the user's data from Core Data
     */
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
    
    /** Handle fetching the user's data from core data
     *
     *  @param completionHandlerWithUserData - the completion handler, including the User's data
     *  @return None - handled by the completion han
     */
    private func performUserFetch(completionHandlerWithUserData: CompletionHandlerWithUserData) {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            completionHandlerWithUserData(success: false, userData: nil, error: error)
        }
        
        /* Guard against user data being not fetched for whatever reason*/
        guard fetchedResultsController.fetchedObjects?.count > 0 else {
            completionHandlerWithUserData(success: false, userData: nil, error: nil)
            return
        }
        
        if let userData = fetchedResultsController.fetchedObjects?[0] as? UserData {
            completionHandlerWithUserData(success: true, userData: userData, error: nil)
        } else {
            completionHandlerWithUserData(success: false, userData: nil, error: Errors.constructError(domain: "ProfileData", userMessage: "An error occured while retrieving your user data.  If the error continues, please sign out and sign back in."))
        }
    }
}