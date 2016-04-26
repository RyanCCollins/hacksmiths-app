//
//  RegistrationData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

protocol RegistrationDelegate {
    func didFinishRegisteringAndCanContinue(withFieldRawValue fieldRawValue: Int, value: String) -> Bool
}

// Temporary class for storing registration data.  Will get wiped out after registration
class RegistrationData: RegistrationDelegate {
    var fullName: String?
    var email: String?
    var password: String?
    
    typealias jsonDict = [String : AnyObject]
    
    var currentField = Field(rawValue: 0)
    static let sharedInstance = RegistrationData()
    
    // Mark: Regular expression for email
    static private let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    // Coordinate setting of the various fields to make this class handle the collection of the data
    // The delegate method will collect the data and also set the next field that needs to be collected
    // Based off of the raw Int value.
    func didFinishRegisteringAndCanContinue(withFieldRawValue fieldRawValue: Int, value: String) -> Bool {
        // Field to return
        var isValid = false
        
        if let theField = Field.init(rawValue: fieldRawValue) {
            //Set our class variable for current field
            currentField = theField
            
            
            // Work through the various fields and set the value for the submitted field.
            // Then, set current field to the next field.
            switch theField {
            case .FullName:
                if isValidEmail(value) {
                    fullName = value
                    currentField = .Email
                    isValid = true
                }
            case .Email:
                if isValidEmail(value) {
                    email = value
                    currentField = .Password
                    isValid = true
                }
            case .Password:
                if isValidPassword(value) {
                    password = value
                    currentField = .None
                }
            case .None:
                return isValid
            }
        }
        return isValid
    }
    
    // Useful for decrementing the current field if the user needs to go back.
    func decrementCurrentField() {
        if currentField?.rawValue > 0 {
            currentField = Field.init(rawValue: (currentField?.rawValue)! - 1)
        }
    }
    
    private func isValidPassword(thePassword: String)-> Bool {
        var isValid = false
        
        guard !thePassword.isEmpty else {
            return false
        }
        
        // Get the simple checks out of the way, such as password length
        if thePassword.length < 8 {
            isValid = false
        } else {
            isValid = true
        }
        
        return isValid
    }
    
    private func isValidEmail(theEmail: String) -> Bool {
        return true
    }
    
    private func isValidFullname(theName: String) -> Bool {
        // If Fullname is empty, return false
        guard !theName.isEmpty else {
            return false
        }
        
        // If the length is greater than 3, return true, otherwise return false.
        if theName.length > 3 {
            return true
        } else {
            return false
        }
    }
    
    
    func submitRegistrationData(completionHandler: CompletionHandler) {
        
        HacksmithsAPIClient.sharedInstance().registerWithEmail(bodyForRegistrationData(), completionHandler: {success, error in
            
            if success {
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: error)
            }
            
        })
    }
    
    private func bodyForRegistrationData() -> jsonDict {
        let body: jsonDict = [
            "fullname": fullName!,
            "email": email!,
            "password" : password!
        ]
        
        return body
    }
}

//MARK: Enumerations for stats and next Field values
extension RegistrationData {
    enum ValidityState {
        case NotValid
        case Custom(String, String)
        case None
    }
    
    // Enumeration that holds the current field for determining what data is not yet filled in
    enum Field: Int {
        case FullName = 0
        case Email = 1
        case Password = 2
        case None = 3
    }
}
