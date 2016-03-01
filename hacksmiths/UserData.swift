//
//  UserData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/16/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class UserData: NSObject {
    var userId: Int?
    var dateAuthenticated: NSDate?
    
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
            NSUserDefaults.standardUserDefaults().valueForKey("authenticated")
        }
    }
    
    func saveDataToUserDefaults() {
        NSUserDefaults.standardUserDefaults().setValue(userId, forKey: "userId")
        NSUserDefaults.standardUserDefaults().setValue(authenticated, forKey: "authenticated")
        NSUserDefaults.standardUserDefaults().setValue(dateAuthenticated, forKey: "dateAuthenticated")
    }
    
    func getDataFromUserDefaults() {
        let authenticated = NSUserDefaults.standardUserDefaults().boolForKey("authenticated")

        if authenticated == true {
            if let id = NSUserDefaults.standardUserDefaults().valueForKey("userId") as? Int {
                
                userId = id
            
            } else {
             
                userId = nil
            
            }
        }
    }
}
