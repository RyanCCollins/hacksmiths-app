//
//  UserData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/16/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import PromiseKit

class UserService {
    var userData: UserData? = nil
    
    /* Singleton shared instance of */
    class func sharedInstance() -> UserService {
        struct Singleton {
            static var sharedInstance = UserService()
        }
        return Singleton.sharedInstance
    }
    
    /** Clear the user records from Core Data, performing user logout
     *
     *  @param None
     *  @return Promise<Void> - A Promise with no return type
     */
    func performLogout() -> Promise<Void> {
        return Promise{resolve, reject in
            let userProfileService = UserProfileService()
            userProfileService.deleteUserDataRecords().then(){Void -> () in
                self.authToken = nil
                self.authenticated = false
                self.dateAuthenticated = nil
                self.userId = nil
                resolve()
            }.error {error in
                reject(error)
            }
        }
    }
    
    /** The User's Authentication token returned from login on server
     */
    var authToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("token") as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "token")
        }
    }
    
    /** Session based authentication.  Determines whether the user has a session stored
     */
    var authenticated: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("authenticated")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "authenticated")
        }
    }
    
    /** The user's ID
     */
    var userId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("userId") as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "userId")
        }
    }
    
    /** The date that the user was authenticated
     */
    var dateAuthenticated: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("dateAuthenticated") as? NSDate
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "dateAuthenticated")
        }
    }
}


