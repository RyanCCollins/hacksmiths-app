//
//  RegistrationPageViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/14/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import TextFieldEffects
import ChameleonFramework

class RegistrationPageViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var fullNameTextField: IsaoTextField!
    @IBOutlet weak var emailTextField: IsaoTextField!
    @IBOutlet weak var passwordTextField: IsaoTextField!
    @IBOutlet weak var debugLabel: UILabel!
    
    // Mark: Regular expression for email
    static private let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    func setupView() {
        setNavigationControllerItems()
        setupViewForNextField()
        debugLabel.alpha = 0.0
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor();
    }
    
    func setNavigationControllerItems() {
        
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(RegistrationPageViewController.submitAndContinue(_:)))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        
        var image: UIImage!
        //Set the image to the x in square if it's the first field, otherwise, the back button.
        if RegistrationData.sharedInstance.currentField == .FullName {
        
            image = UIImage(named: "x-in-square")
            
        } else {
            
            image = UIImage(named: "backward-arrow")
        }
        
        // Set the right bar button title to Done if we are on the last text field.
        if RegistrationData.sharedInstance.currentField == .None {
            rightBarButtonItem.title = "Done"
        }
        
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(RegistrationPageViewController.dismissViewController(_:)))
        leftBarButtonItem.tintColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setupTextField(textField: IsaoTextField){
        textField.addTarget(self, action: #selector(RegistrationPageViewController.validateTextEntry), forControlEvents: UIControlEvents.EditingChanged)
        textField.becomeFirstResponder()
        textField.delegate = self
    }

    
    func validateTextEntry() -> Bool {
        return true
    }
    
    func submitAndContinue(sender: AnyObject) {
        
        if RegistrationData.sharedInstance.currentField == .FullName {
            
            let fullname = fullNameTextField.text!
            
            if isValidFullname(fullname) {
                
                RegistrationData.sharedInstance.didFinishRegistering(withFieldRawValue: 0, value: fullname)
                goToNextView(self)
            } else {
                showDebugLabel(withText: "Please enter your full name, both first and last")
                
            }
        } else if RegistrationData.sharedInstance.currentField == .Email {
            
            let email = emailTextField.text
            if isValidEmail(email!) {
                RegistrationData.sharedInstance.didFinishRegistering(withFieldRawValue: 1, value: email!)
                goToNextView(self)
            } else {
                showDebugLabel(withText: "Please enter a valid email address")
            }
        
        } else if RegistrationData.sharedInstance.currentField == .Password {
            let password = passwordTextField.text ?? ""
            if isValidPassword(password) {
                RegistrationData.sharedInstance.didFinishRegistering(withFieldRawValue: 2, value: passwordTextField.text!)
               completeRegistration()
            } else {
                showDebugLabel(withText: "Please ensure that your password is at least 8 characters.")
            }
        }
    }
    
    private func isValidPassword(thePassword: String)-> Bool {
        
        // Get the simple checks out of the way, such as password length
        if thePassword.length < 8 {
            return false
        } else {
            return true
        }
        
    }
    
    // From an open source project I worked on by Ian Gristock & Ivan Lares
    // https://github.com/teamhacksmiths/food-drivr-ios/blob/b4571b58894be2ed29dbb1e32d1eacd587740ad5/hackathon-for-hunger/VSUserInfoViewController.swift
    private func isValidEmail(theEmail: String) -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@", RegistrationPageViewController.emailRegEx)
        return emailTest.evaluateWithObject(theEmail)
    }
    
    private func isValidFullname(theName: String) -> Bool {
        
        // If the length is greater than 3, return true, otherwise return false.
        if theName.rangeOfString(" ") != nil {
            return true
        } else {
            return false
        }
    }
    
    func showDebugLabel(withText text: String) {
        debugLabel.text = text
        debugLabel.fadeIn()
    }
    
    
    func completeRegistration() {
        RegistrationData.sharedInstance.submitRegistrationData({success, error in
            if error != nil {
                
                self.alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
                
            } else {
                
                self.dismissViewControllerAnimated(true, completion: {void in
                    
                })
            }
        })

    }
    
    // Responsible for making changes to the UI that rely specifically
    // On the value of the next field
    func setupViewForNextField() {
        if let currentField = RegistrationData.sharedInstance.currentField {
            switch currentField {
            case .FullName:
                view.backgroundColor = UIColor.flatSkyBlueColor()
                emailTextField.hidden = true
                passwordTextField.hidden = true
                fullNameTextField.hidden = false
                setupTextField(fullNameTextField)
            case .Email:
                view.backgroundColor = UIColor.flatRedColor()
                fullNameTextField.hidden = true
                passwordTextField.hidden = true
                emailTextField.hidden = false
                headerLabel.text = "What is your email?"
                setupTextField(emailTextField)
            case .Password:
                view.backgroundColor = UIColor.flatMintColorDark()
                fullNameTextField.hidden = true
                emailTextField.hidden = true
                passwordTextField.hidden = false
                setupTextField(passwordTextField)
            default:
                break
            }
        }
    
    }
    
    func goToNextView(sender: AnyObject) {
        
        if validateTextEntry() == true {
            let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("RegistrationPageViewController") as! RegistrationPageViewController
            
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func dismissViewController(sender: AnyObject) {
        if navigationController?.viewControllers.count > 1 {
            
            RegistrationData.sharedInstance.decrementCurrentField()
            navigationController?.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension RegistrationPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == nil || textField.text == "" {
            
            return false
        }
        submitAndContinue(self)
        return true
    }
}
