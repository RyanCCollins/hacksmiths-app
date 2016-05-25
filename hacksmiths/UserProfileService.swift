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
    func getProfile() -> Promise<UserData?> {
        return Promise{resolve, reject in
            let router = UserProfileRouter(endpoint: .GetProfile())
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON{
                    response in
                    switch response.result {
                    case .Success(let JSON):
                        guard let profileDict = JSON[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile] as? JsonDict,
                            let userJSON = UserJSONObject(userData: profileDict) else {
                                reject(GlobalErrors.MissingData)
                                break
                        }
                        
                        let userData = UserData(json: userJSON, context: GlobalStackManager.SharedManager.sharedContext)
                        print("Created user with data: \(userData)")
                        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        
                        resolve(userData)
                    case .Failure(let error):
                        reject(error as NSError)
                    }
            }
        }
    }
    
    func updateProfile(userJSON: UserJSONObject) -> Promise<Void> {
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
}

struct UserName: Decodable {
    let name: String
    init?(json: JSON) {
        let firstName: String = ("name.first" <~~ json)!
        let lastName: String = ("name.last" <~~ json)!
        name = "\(firstName) \(lastName)"
    }
}

struct UserJSON: Decodable {
    let name: String
    let bio: String?
    let website: String?
    let email: String?
    let isPublic: Bool
    let mobile: Bool
    let needsAMentor: Bool
    let isAvailableForEvents: Bool
    let availabilityExplanation: String?
    let imageURL: String
    let isTopContributor: Bool
    let isAvailableAsAMentor: String?
    let mobileNotifications: Bool
    
    init?(json: JSON) {
        let nam
        "name"
    }
    func getFullName(json: JSON) {
        let first = "user.first" <~~ json
        let last = "user.last" <~~ json
    }
}