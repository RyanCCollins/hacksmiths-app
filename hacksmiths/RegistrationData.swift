//
//  RegistrationData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

protocol RegistrationDelegate {
    func didFinishRegistering(withFieldRawValue fieldRawValue: Int, value: String)
}

// Temporary class for storing registration data.  Will get wiped out after registration
class RegistrationData: RegistrationDelegate {
    var fullName: String?
    var email: String?
    var password: String?
    
    var currentField = Field(rawValue: 0)
    static let sharedInstance = RegistrationData()
    
    // Coordinate setting of the various fields to make this class handle the collection of the data
    // The delegate method will collect the data and also set the next field that needs to be collected
    // Based off of the raw Int value.
    func didFinishRegistering(withFieldRawValue fieldRawValue: Int, value: String) {
        
        if let theField = Field.init(rawValue: fieldRawValue) {
            //Set our class variable for current field
            currentField = theField
            
            // Work through the various fields and set the value for the submitted field.
            // Then, set current field to the next field.
            switch theField {
            case .FullName:
                fullName = value
                currentField = .Email
            case .Email:
                email = value
                currentField = .Password
            case .Password:
                password = value
                currentField = .None
            case .None:
                break
            }
        }
    }
    
    // Useful for decrementing the current field if the user needs to go back.
    func decrementCurrentField() {
        if currentField?.rawValue > 0 {
            currentField = Field.init(rawValue: (currentField?.rawValue)! - 1)
        }
    }
    
    func submitRegistrationData(completionHandler: CompletionHandler) {
        
        HacksmithsAPIClient.sharedInstance().registerWithEmail(bodyForRegistrationData(), completionHandler: {success, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                completionHandler(success: true, error: nil)
            }
            
        })
    }
    
    private func bodyForRegistrationData() -> JsonDict {
        let body: JsonDict = [
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
