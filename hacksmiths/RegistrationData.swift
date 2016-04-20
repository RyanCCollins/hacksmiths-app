//
//  RegistrationData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

protocol RegistrationDelegate {
    func didFinishRegistering(viewController: UIViewController, field: AnyObject, value: String)
}

// Temporary class for storing registration data.  Will get wiped out after registration
class RegistrationData: RegistrationDelegate {
    var fullName: String?
    var email: String?
    var password: String?
    var currentField = CurrentField.FullName

    class func sharedInstanced() -> RegistrationData {
        struct Singleton {
            static var sharedInstance = RegistrationData()
        }
        return Singleton.sharedInstance
    }
    
    func didFinishRegistering(viewController: UIViewController, field: AnyObject, value: String) {
        
    }
    
    // Returns whether the data is complete.  Convenience for checking all the fields against nil
    func isComplete()-> Bool {
        if fullName == nil || email == nil || password == nil {
            return false
        }
        return true
    }
    
    // Enumeration that holds the current field for determining what data is not yet filled in
    enum CurrentField: String {
        case FullName = "FullName"
        case Email = "Email"
        case Password = "Password"
    }
}
