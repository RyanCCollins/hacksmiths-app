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
    @IBOutlet weak var firstNameTextField: IsaoTextField!
    @IBOutlet weak var lastNameTextField: IsaoTextField!
    @IBOutlet weak var emailTextField: IsaoTextField!
    @IBOutlet weak var passwordTextField: IsaoTextField!
    @IBOutlet weak var debugLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        setupTextFields()
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor();
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(RegistrationPageViewController.goToNextView(_:)))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        let xImage = UIImage(named: "x-in-square")
        let leftBarButtonItem = UIBarButtonItem(image: xImage, style: .Plain, target: self, action: #selector(RegistrationPageViewController.dismissViewController(_:)))
        leftBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setupTextFields(){
        firstNameTextField.addTarget(self, action: #selector(RegistrationPageViewController.validateTextEntry), forControlEvents: UIControlEvents.EditingChanged)
        firstNameTextField.becomeFirstResponder()
        firstNameTextField.delegate = self
    }

    
    func validateTextEntry() -> Bool {
        return true
    }
    
    func submitAndContinue() {
        
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
        // Go to the next screen
        goToNextView(self)
        return true
    }
}
