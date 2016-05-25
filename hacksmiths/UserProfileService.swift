//
//  UserProfileService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Gloss
import CoreData

class UserProfileService {
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
    
    func updateProfile(userJSON: UserJSONObject, userID: String) -> Promise<Void> {
        return Promise{resolve, reject in
            let router = UserProfileRouter(endpoint: .UpdateProfile(userJSON: userJSON, userID: userID))
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
}