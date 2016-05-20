//
//  LoginViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import LocalAuthentication
import SwiftyButton

class LoginViewController: UIViewController {
    
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var onepasswordButton: UIButton!

    
    let loginButton = SwiftyCustomContentButton()
    
    var has1PasswordLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure buttons based on availability */
        configureLoginButtons()
        configureOnePasswordButton()
    }
    

    func configureLoginButtons() {
        onepasswordButton.enabled = true
    }
    

    @IBAction func didTapSkipUpInside(sender: AnyObject) {
        dismissLoginView(false)
    }

    func configureOnePasswordButton() {
        /* Hide 1Password Button if not installed */
        self.onepasswordButton.hidden = !OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
    }
    
    @IBAction func didTapOnePasswordButtonUpInside(sender: AnyObject) {
        findLoginFrom1Password(sender)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToKeyboardNotification()
    }

    func dismissLoginView(loginWasSuccessful: Bool) {
        /* If we successfully logged in, send a notification that says the login was successful */
        if loginWasSuccessful {
            let loginWasSuccessful = NSNotification(name: Notifications.LoginWasSuccessful, object: self)
            NSNotificationCenter.defaultCenter().postNotification(loginWasSuccessful)
        }
        /* Dismiss the login view with animation */
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapLoginButtonUpInside(sender: AnyObject) {
        if !credentialsAreValid() {
            alertController(withTitles: ["OK"], message: "Please enter a valid username and password", callbackHandler: [nil])
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        authenticateUser(usernameTextField.text!, password: passwordTextField.text!)
    }
    
    func authenticateUser(username: String, password: String) {
        HacksmithsAPIClient.sharedInstance().authenticateWithCredentials(username, password: password, completionHandler: {success, error in
            if error != nil {
                self.alertController(withTitles: ["OK"], message: "We were unable to authenticate your account.  Please check your password and try again.", callbackHandler: [nil])
            }
            
            if success {
                self.dismissLoginView(true)
            }
        })
    }

    
    func findLoginFrom1Password(sender:AnyObject) -> Void {
        OnePasswordExtension.sharedExtension().findLoginForURLString("http://hacksmiths.io", forViewController: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary == nil {
                if error!.code != Int(AppExtensionErrorCodeCancelledByUser) {
                    
                    print("Error invoking 1Password App Extension for find login: \(error)")
                }
                return
            }
            
            if let foundUsername = loginDictionary?[AppExtensionUsernameKey] as? String, foundPassword = loginDictionary?[AppExtensionPasswordKey] as? String {
                
                self.passwordTextField.text = foundPassword
                self.usernameTextField.text = foundUsername
                
                self.authenticateUser(foundUsername, password: foundPassword)
                
            }
        })
    }
    
    func saveLoginTo1Password(sender: AnyObject) {
        /* Create a login dictionary to save to onepassword */
        let newLoginDictionary : [String: AnyObject] = [
            AppExtensionTitleKey: "Hacksmiths",
            AppExtensionUsernameKey: self.usernameTextField.text!,
            AppExtensionPasswordKey: self.passwordTextField.text!,
            AppExtensionNotesKey: "Saved with the Hacksmiths app",
            AppExtensionSectionTitleKey: "Hacksmiths App",
        ]
        
        /* Create a passwordDetail dictionary to define password characteristics for onepassword */
        let passwordDetailsDictionary : [String: AnyObject] = [
            AppExtensionGeneratedPasswordMinLengthKey: 6,
            AppExtensionGeneratedPasswordMaxLengthKey: 50
        ]
        
        // 3.
        OnePasswordExtension.sharedExtension().storeLoginForURLString(HacksmithsAPIClient.Constants.BaseURL, loginDetails: newLoginDictionary, passwordGenerationOptions: passwordDetailsDictionary, forViewController: self, sender: sender, completion: {(loginDictionary, error) -> Void in
            
            if loginDictionary == nil {
                if (error!.code != Int(AppExtensionErrorCodeCancelledByUser))  {
                    print("Error invoking 1Password App Extension for find login: \(error)")
                }
                return
            }
            
            let foundUsername = loginDictionary!["username"] as! String
            let foundPassword = loginDictionary!["password"] as! String
            
            HacksmithsAPIClient.sharedInstance().authenticateWithCredentials(foundUsername, password: foundPassword, completionHandler: {success, error in
                
                if error != nil {

                    self.alertController(withTitles: ["OK"], message: "We were unable to authenticate your account.  Please check your password and try again.", callbackHandler: [nil])

                }
                
                if success {
                    
                    self.dismissLoginView(true)

                }
                
            })
        })
    }
    
    
    func credentialsAreValid() -> Bool{
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            return false
        } else {
            return true
        }
    }

}

extension LoginViewController {
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        /* Enable save button if fields are filled out  */
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        
        view.frame.origin.y = -getKeyboardHeight(notification)
        
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}