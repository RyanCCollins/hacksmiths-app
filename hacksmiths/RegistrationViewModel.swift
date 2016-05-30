//
//  RegistrationData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

protocol RegistrationDelegate {
    func didFinishRegistering(withField field: RegistrationViewModel.RegistrationField, value: String)
}

/* Exploring Model View / View Model paradigm for Registration 
 * This class takes care of talking with the model and talking to the view
 */
class RegistrationViewModel: RegistrationDelegate {
    
    /* Initialize the JSON object with empty values */
    var registrationJSON = RegistrationJSON(fullname: "", email: "", password: "")
    
    var currentField = RegistrationField(rawValue: 0)
    static let sharedInstance = RegistrationViewModel()
    
    // Coordinate setting of the various fields to make this class handle the collection of the data
    // The delegate method will collect the data and also set the next field that needs to be collected
    // Based off of the raw Int value.
    func didFinishRegistering(withField field: RegistrationField, value: String) {
        
        // Work through the various fields and set the value for the submitted field.
        // Then, set current field to the next field.
        switch field {
        case .FullName:
            registrationJSON.fullname = value
            currentField = .Email
        case .Email:
            registrationJSON.email = value
            currentField = .Password
        case .Password:
            registrationJSON.password = value
            currentField = .None
        case .None:
            break
        }
    }
    
    /* Submit registration data to the API */
    func submitRegistrationData(completionHandler: CompletionHandler) {
        HacksmithsAPIClient.sharedInstance().registerWithEmail(registrationJSON, completionHandler: {success, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                completionHandler(success: true, error: nil)
            }
        })
    }
    
    // Useful for decrementing the current field if the user needs to go back.
    func decrementCurrentField() {
        if currentField?.rawValue > 0 {
            currentField = RegistrationField.init(rawValue: (currentField?.rawValue)! - 1)
        }
    }
    
    func incrementCurrentField() {
        if let field = currentField {
            currentField = RegistrationField.init(rawValue: (field.rawValue) + 1)
        }
    }
}

//MARK: Enumerations for states and next Field values
extension RegistrationViewModel {
    enum ValidityState {
        case NotValid
        case Custom(String, String)
        case None
    }
    
    // Enumeration that holds the current field for determining what data is not yet filled in
    enum RegistrationField: Int {
        case FullName = 0,
             Email,
             Password,
             None
    }
}
