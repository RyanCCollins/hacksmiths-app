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
    let xInSquareImage = UIImage(named: "x-in-square")
    let backwardArrowImage = UIImage(named: "backward-arrow")
    
    // Mark: Regular expression for email
    static private let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    
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
    
    func didChangeTextInTextField(sender: IsaoTextField) {
        if validateField(RegistrationData.sharedInstance.currentField!, withValue: sender.text) {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func setNavigationControllerItems() {
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(RegistrationPageViewController.processSubmission(_:)))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        
        // Set the right bar button title to Done if we are on the last text field.
        if RegistrationData.sharedInstance.currentField == .None {
            rightBarButtonItem.title = "Done"
        }
        let itemButtonImage = buttonItemImage(forField: RegistrationData.sharedInstance.currentField!)
        let leftBarButtonItem = UIBarButtonItem(image: itemButtonImage, style: .Plain, target: self, action: #selector(RegistrationPageViewController.proceedBackwards(_:)))
        leftBarButtonItem.tintColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func buttonItemImage(forField field: RegistrationData.RegistrationField) -> UIImage {
        switch field {
        case .FullName:
            return xInSquareImage!
        default:
            return backwardArrowImage!
        }
    }
    
    func setupTextField(textField: IsaoTextField){
        textField.addTarget(self, action: #selector(RegistrationPageViewController.didChangeTextInTextField), forControlEvents: UIControlEvents.EditingChanged)
        textField.becomeFirstResponder()
        textField.delegate = self
    }

    

    
    func debugMessage(forField field: RegistrationData.RegistrationField) -> String {
        switch field {
        case .Email:
            return "Please enter a valid email address"
        case .FullName:
            return "Please enter your full name, both first and last"
        case .Password:
            return "Please ensure that your password is at least 8 characters."
        default:
            return ""
        }
    }
    
    func dataValue(forField field: RegistrationData.RegistrationField) -> String? {
        switch field {
        case .FullName: return fullNameTextField.text
        case .Email: return emailTextField.text
        case .Password: return passwordTextField.text
        default: return nil
        }
        
    }
    
    private func validateField(field: RegistrationData.RegistrationField, withValue value: String?) -> Bool {
        guard value != nil else {
            return false
        }
        
        switch field {
        case .FullName:
            return value?.rangeOfString(" ") != nil
        case .Email:
            let emailTest = NSPredicate(format: "SELF MATCHES %@", RegistrationPageViewController.emailRegEx)
            return emailTest.evaluateWithObject(value!)
        case .Password:
            return value!.length > 8
        default:
            return false
        }
    }
    
    
    func showDebugLabel(withText text: String) {
        debugLabel.text = text
        debugLabel.fadeIn()
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
                headerLabel.text = "What should we call you?"
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
                headerLabel.text = "Set your password."
                passwordTextField.hidden = false
                setupTextField(passwordTextField)
            default:
                break
            }
        }
    
    }
    
    func proceedOrCompleteRegistration(forField field: RegistrationData.RegistrationField){
        switch field {
        case .Password:
            submitRegistration()
        default:
            proceedForwards(self)
        }
    }
    
    func processSubmission(sender: AnyObject) {
        let currentField = RegistrationData.sharedInstance.currentField
        let currentValue = dataValue(forField: currentField!)
        
        if validateField(currentField!, withValue: currentValue) {
            RegistrationData.sharedInstance.didFinishRegistering(withField: currentField!, value: currentValue!)
        } else {
            showDebugLabel(withText: debugMessage(forField: currentField!))
        }
    }
    
    
    /* Continue forwards in registration process
     * By pushing the next view controller onto the stack.
     */
    func proceedForwards(sender: AnyObject) {
        let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("RegistrationPageViewController") as! RegistrationPageViewController
        
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    /* Either backs up the process of registration, or dismisses the process
     * All together, leading back to presenting view.
     */
    func proceedBackwards(sender: AnyObject) {
        if navigationController?.viewControllers.count > 1 {
            RegistrationData.sharedInstance.decrementCurrentField()
            navigationController?.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /* Either backs up the process of registration, or dismisses the process
     * All together, leading back to presenting view.
     */
    func submitRegistration() {
        RegistrationData.sharedInstance.submitRegistrationData({success, error in
            if error != nil {
                self.alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
            } else {
                self.dismissViewControllerAnimated(true, completion: {void in
                })
            }
        })
        
    }
}

extension RegistrationPageViewController: UITextFieldDelegate {
    /* Delegate callback for text field should return.
     * Validates entry and then returns true if valid.
     * @return - Bool - Determination of whether the registration process can continue or not.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if validateField(RegistrationData.sharedInstance.currentField!, withValue: textField.text) {
            proceedOrCompleteRegistration(forField: RegistrationData.sharedInstance.currentField!)
            return true
        } else {
            return false
        }
    }
}
