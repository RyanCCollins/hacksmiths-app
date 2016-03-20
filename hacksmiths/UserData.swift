//
//  UserData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/16/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class UserData: NSObject {

    
    /* Singleton shared instance of */
    class func sharedInstance() -> UserData {
        struct Singleton {
            static var sharedInstance = UserData()
        }
        return Singleton.sharedInstance
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
