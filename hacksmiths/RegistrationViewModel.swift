//
//  RegistrationData.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

/** The registration delegate is used to communicate between the view model and view.
 */
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
    
    /** called when the field did finish registering with the value
     *
     *  @param field - the Registration Field enum value that corresponds with a text field from the view
     *  @param value - the value that is used to finish registration.
     *  @return None
     */
    func didFinishRegistering(withField field: RegistrationField, value: String) {
        
        /* Work through the fields and set the value for the submitted field.
         * Then, set current field to the next field.
         */
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
    
    func resetRegistration() {
        currentField = RegistrationField(rawValue: 0)
    }
    
    /** Submit registration data to the API with a completion handler
     *
     *  @param completionHandler - the completionHandler to be called back when complete
     *  @return None
     */
    func submitRegistrationData(completionHandler: CompletionHandler) {
        HacksmithsAPIClient.sharedInstance().registerWithEmail(registrationJSON, completionHandler: {success, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                self.resetRegistration()
                completionHandler(success: true, error: nil)
            }
        })
    }
    
    /** Decrement the current field enum value
     */
    func decrementCurrentField() {
        if currentField?.rawValue > 0 {
            currentField = RegistrationField.init(rawValue: (currentField?.rawValue)! - 1)
        }
    }
    
    /** Increment the current field enum value
     */
    func incrementCurrentField() {
        if let field = currentField {
            currentField = RegistrationField.init(rawValue: (field.rawValue) + 1)
        }
    }
}

//MARK: Enumerations for states and next Field values
extension RegistrationViewModel {

    // Enumeration that holds the current field for determining what data is not yet filled in
    enum RegistrationField: Int {
        case FullName = 0,
             Email,
             Password,
             None
    }
}
