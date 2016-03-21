//
//  RegistrationData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

// Temporary class for storing registration data.  Will get wiped out after registration
class RegistrationData {
    var nameFirst: String?
    var nameLast: String?
    var email: String?
    var password: String?
    
    class func sharedInstanced() -> RegistrationData {
        struct Singleton {
            static var sharedInstance = RegistrationData()
        }
        return Singleton.sharedInstance
    }
    
    // Returns whether the data is complete.  Convenience for checking all the fields against nil
    func isComplete()-> Bool {
        if nameFirst == nil || nameLast == nil || email == nil || password == nil {
            return true
        }
        return false
    }
}
