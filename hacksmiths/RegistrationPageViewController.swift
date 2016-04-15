//
//  RegistrationPageViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/14/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class RegistrationPageViewController: UIViewController {
    
    var textField: UITextField!
    var debugLabel: UILabel!
    
    enum Fields: String {
        case FirstName = "FirstName"
        case LastName = "LastName"
        case Email = "Email"
        case Password = "Password"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setupView() {
        textField.delegate = self
        textField.addTarget(self, action: "validateTextEntry:", forControlEvents: UIControlEvents.EditingChanged)
        textField.becomeFirstResponder()
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor();
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "goToNext:")
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        let xImage = UIImage(named: "x-in-square")
        let leftBarButtonItem = UIBarButtonItem(image: xImage, style: .Plain, target: self, action: "dismissView:")
        leftBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setKeyboard() {
        
    }
    
    func validateTextEntry(sender: UITextField) {
        
    }
    
    func submitAndContinue() {
        
    }
    
    func goToNextView(sender: AnyObject) {
        
    }
    
}

extension RegistrationPageViewController {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == nil || textField.text == "" {
            
            return false
        }
        // Go to the next screen
        goToNextView(self)
        return true
    }
}
