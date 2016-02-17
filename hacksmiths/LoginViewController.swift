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
    
    let AKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!

    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var onepasswordButton: UIButton!
    
    let loginButton = SwiftyCustomContentButton()
    
    /* One password and touch ID variables */
    var context = LAContext()

    var has1PasswordLogin: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /* Configure buttons based on availability */
        configureLoginButtons()
        configureTouchID()
        configureOnePasswordButton()
    }
    
    func configureLoginButtons() {
        
        loginButtonView.addSubview(loginButton)
        loginButton.autoPinEdgesToSuperviewEdges()
        
        setButtonLoading("Login", loading: false)
        
        loginButton.buttonColor = UIColor(hex: "#25293c")
        loginButton.shadowColor = UIColor(hex: "#808c8d")
        
        loginButton.addTarget(self, action: "loginOrRegisterAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        loginButton.tag = loginButtonTag
        debugLabel.hidden = true
        onepasswordButton.enabled = true
        
//        if hasLogin {
//            loginButton.setTitle("Login", forState: UIControlState.Normal)
//            loginButton.tag = loginButtonTag
//            debugLabel.hidden = true
//            onepasswordButton.enabled = true
//        } else {
//            loginButton.setTitle("Register", forState: UIControlState.Normal)
//            loginButton.tag = createLoginButtonTag
//            debugLabel.hidden = false
//            onepasswordButton.enabled = false
//        }
        
        
        if let storedUsername = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
            usernameTextField.text = storedUsername as String
        }
    }
    
    @IBAction func didTapSkipUpInside(sender: AnyObject) {
        dismissLoginView(false)
    }
    
    func setButtonLoading(message: String, loading: Bool) {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        
        if loading == true {
            
            dispatch_async(GlobalMainQueue, {
                
                self.loginButton.customContentView.addSubview(indicator)
                indicator.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 0), excludingEdge: .Right)
                indicator.startAnimating()
                
                let label = UILabel()
                self.loginButton.titleLabel?.text = ""
                
                self.loginButton.customContentView.addSubview(label)
                label.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10), excludingEdge: .Left)
                label.autoPinEdge(.Left, toEdge: .Right, ofView: indicator, withOffset: 10)
                label.text = message
                label.textColor = UIColor.whiteColor()
            })
        } else {
            /* Remove the custom content view */
            dispatch_async(GlobalMainQueue, {
                self.loginButton.customContentView.hideLoading()
                
                self.loginButton.titleLabel!.text = message
            })
        }


    }
    
    func configureTouchID() {
        touchIDButton.hidden = true
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            touchIDButton.hidden = false
        }
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToKeyboardNotification()
    }
    
    @IBAction func didTapTouchIDButtonUpInside(sender: AnyObject) {
        authenticateWithTouchID()
    }
    
    func authenticateWithTouchID() {
         /* If we can evaluate with touch ID sensor, carry on*/
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            /* If we can evaluate with touch ID sensor, carry on*/
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Logging in with Touch ID", reply: { success, error in
                    
                    /* Dismiss the login view controller and continue if successful */
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if success {
                            self.dismissLoginView(true)
                        }
                        
                        if error != nil {
                            
                            /* To do: refactor to user global errors */
                            var message = ""
                            var shouldShowAlert = false
                            
                            /* Check if there is an error code and create an error message for it. */
                            switch(error!.code) {
                            case LAError.AuthenticationFailed.rawValue:
                                message = "There was a problem verifying your identity."
                                shouldShowAlert = true
                                break;
                            case LAError.UserCancel.rawValue:
                                message = "You pressed cancel."
                                shouldShowAlert = true
                                break;
                            case LAError.UserFallback.rawValue:
                                message = "You pressed password."
                                shouldShowAlert = true
                                break;
                            default:
                                shouldShowAlert = true
                                message = "Touch ID may not be configured"
                                break;
                            }
                            
                            if shouldShowAlert {
                                self.alertController(withTitles: ["OK"], message: message, callbackHandler: [nil])
                            }
                            
                            
                        }
                    })
                    
            })
        } else {
            
            self.alertController(withTitles: ["OK"], message: "Unable to use TouchID on your device.", callbackHandler: [nil])
            
        }
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
    
    func loginOrRegisterAction(sender: AnyObject){
        
        if !credentialsAreValid() {
            alertController(withTitles: ["OK"], message: "Please enter a valid username and password", callbackHandler: [nil])
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
//        if sender.tag == createLoginButtonTag {
//            
//            let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
//            
//            if hasLoginKey == false {
//                NSUserDefaults.standardUserDefaults().setValue(self.usernameTextField.text, forKey: "username")
//            }
//        
//
//            AKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
//            AKeychainWrapper.writeToKeychain()
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
//            NSUserDefaults.standardUserDefaults().synchronize()
//            loginButton.tag = loginButtonTag
        

//        } else if sender.tag == loginButtonTag {
        
            setButtonLoading("Logging in...", loading: true)
            
            if checkLogin(usernameTextField.text!, password: passwordTextField.text!) {
                
                HacksmithsAPIClient.sharedInstance().authenticateWithCredentials(usernameTextField.text!, password: passwordTextField.text!, completionHandler: {success, error in
                    
                    if error != nil {
                        self.setButtonLoading("Login", loading: false)
                        self.alertController(withTitles: ["OK"], message: "We were unable to authenticate your account.  Please check your password and try again.", callbackHandler: [nil])
                    }
                    
                    if success {
                        
                        self.dismissLoginView(true)
                    }
                    
                })
            
            } else {
                
                alertController(withTitles: ["OK"], message: "There was an issue logging you in.  Please check your username and password and try again.", callbackHandler: [nil])
                
            }
//        }
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
                if self.checkLogin(foundUsername, password: foundPassword) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                print("Unable to find username and password from onepassword")
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
            
            // 6.
            if self.checkLogin(foundUsername, password: foundPassword) {
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                
                self.alertController(withTitles: ["OK"], message: "Sorry, but something went wrong while getting your credentials.  Please try again.", callbackHandler: [nil])
                
            }
        })
    }
    
    
    func checkLogin(username: String, password: String ) -> Bool {
        if password == AKeychainWrapper.myObjectForKey("v_Data") as? String &&
            username == NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
                return true
        } else {
            return false
        }
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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