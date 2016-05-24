//
//  UserData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/16/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//


class UserService {
    var userData: UserData? = nil
    
    /* Singleton shared instance of */
    class func sharedInstance() -> UserService {
        struct Singleton {
            static var sharedInstance = UserService()
        }
        return Singleton.sharedInstance
    }
    
    func performLogout() {
        authenticated = false
        userId = nil
        dateAuthenticated = nil
    }
    
    var authenticated: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("authenticated")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "authenticated")
        }
    }
    
    var userId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("userId") as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "userId")
        }
    }
    
    var dateAuthenticated: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("dateAuthenticated") as? NSDate
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "dateAuthenticated")
        }
    }
}


