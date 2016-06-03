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
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var onepasswordButton: UIButton!
    
    var loginPresenter: LoginPresenter?
    var has1PasswordLogin: Bool = false
    var activityIndicator: IGActivityIndicatorView!
    
    /** MARK: Lifecycle methods
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure buttons based on availability */
        configureLoginButtons()
        configureOnePasswordButton()
        configureActivityIndicator()
        loginPresenter = LoginPresenter()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginPresenter?.attachView(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loginPresenter?.detachView()
    }
    
    /** Setup the activity indicator within the view
     */
    func configureActivityIndicator() {
        activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Signing in")
    }
    
    /** Configure the one password button, setting it to be showing if the extension is availabld
     */
    func configureLoginButtons() {
        onepasswordButton.hidden = !OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
    }
    
    /** The User tapped the cancel / Skip button, so proceed
     */
    @IBAction func didTapSkipUpInside(sender: AnyObject) {
        dismissLoginView(false)
    }
    
    /** Configure the one password button for the user.
     */
    func configureOnePasswordButton() {
        /* Hide 1Password Button if not installed */
        self.onepasswordButton.hidden = !OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
    }
    
    @IBAction func didTapOnePasswordButtonUpInside(sender: AnyObject) {
        findLoginFrom1Password(sender)
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
        if !credentialsAreNotEmpty() {
            alertController(withTitles: ["OK"], message: "Please enter a valid username and password", callbackHandler: [nil])
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        loginPresenter?.authenticateUser(usernameTextField.text!, password: passwordTextField.text!)
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
                
                self.loginPresenter?.authenticateUser(foundUsername, password: foundPassword)
            }
        })
    }
    
    
    func credentialsAreNotEmpty() -> Bool{
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            return false
        } else {
            return true
        }
    }
    
    func findSavedCredentials(sender: AnyObject){
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
                
                self.loginPresenter!.authenticateUser(foundUsername, password: foundPassword)
                
            }
        })
    }

}

extension LoginViewController: LoginView {
    /** Show / Hide loading indicator through Presenter Protocol
     */
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
    
    func didLogin(didSucceed: Bool, didFail error: NSError?) {
        finishLoading()
        if error != nil {
            alertController(withTitles: ["OK"], message: "We were unable to authenticate your account.  Please check your password and try again.", callbackHandler: [nil])
        } else if didSucceed {
            dismissLoginView(true)
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}

extension LoginViewController {
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
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