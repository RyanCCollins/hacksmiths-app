//
//  RegistrationPageViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/14/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import TextFieldEffects


class RegistrationPageViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var fullNameTextField: IsaoTextField!
    @IBOutlet weak var emailTextField: IsaoTextField!
    @IBOutlet weak var passwordTextField: IsaoTextField!
    @IBOutlet weak var debugLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setNavigationControllerItems()
    }
    
    func setupView() {
        setupViewForNextField()
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor();
    }
    
    func setNavigationControllerItems() {
        
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(RegistrationPageViewController.submitAndContinue(_:)))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        
        var image: UIImage!
        //Set the image to the x in square if it's the first field, otherwise, the back button.
        if RegistrationData.sharedInstance.nextField == .FullName {
        
            image = UIImage(named: "x-in-square")
            
        } else {
            
            image = UIImage(named: "backward-arrow")
        }
        
        // Set the right bar button title to Done if we are on the last text field.
        if RegistrationData.sharedInstance.nextField == .None {
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
        
        if RegistrationData.sharedInstance.nextField == .FullName {

            if RegistrationData.sharedInstance.didFinishRegisteringAndCanContinue(withFieldRawValue: 0, value: fullNameTextField.text!) {
                goToNextView(self)
            } 
        } else if RegistrationData.sharedInstance.nextField == .Email {
            
            RegistrationData.sharedInstance.didFinishRegisteringAndCanContinue(withFieldRawValue: 1, value: emailTextField.text!)
            goToNextView(self)
            
        } else if RegistrationData.sharedInstance.nextField == .Password {
            
            RegistrationData.sharedInstance.didFinishRegisteringAndCanContinue(withFieldRawValue: 2, value: passwordTextField.text!)
            goToNextView(self)
            
        } else if RegistrationData.sharedInstance.nextField == .None {
            RegistrationData.sharedInstance.submitRegistrationData({success, error in
                if error != nil {
                    self.alertController(withTitles: ["Ok"], message: "Sorry, but we were unable to create your accont.  Please try again.", callbackHandler: [nil])
                
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                }
            })
        }
    }
    
    
    // Responsible for making changes to the UI that rely specifically
    // On the value of the next field
    func setupViewForNextField() {
        if let nextField = RegistrationData.sharedInstance.nextField {
            switch nextField {
            case .FullName:
                emailTextField.hidden = true
                passwordTextField.hidden = true
                fullNameTextField.hidden = false
                setupTextField(fullNameTextField)
            case .Email:
                view.backgroundColor = UIColor.redColor()
                fullNameTextField.hidden = true
                passwordTextField.hidden = true
                emailTextField.hidden = false
                headerLabel.text = "What is your email?"
                setupTextField(emailTextField)
            case .Password:
                view.backgroundColor = UIColor.greenColor()
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
