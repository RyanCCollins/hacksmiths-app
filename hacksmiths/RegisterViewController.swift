//
//  RegisterViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import SwiftyButton

class RegisterViewController: UIViewController {
    @IBOutlet var signMeUpButton: SwiftyButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapSignUpUpInside(sender: AnyObject) {
        submitForm()
    }
    
    func submitForm() {
        if formIsValid() {
            // TODO: Submit form via API.
        }
    }
    
    func formIsValid() -> Bool {
        if firstNameTextField.text == nil || lastNameTextField.text == nil {
            alertController(withTitles: ["OK"], message: "Please enter your first and last name", callbackHandler: [nil])
            return false
        }
        
        if emailTextField.text == nil || passwordTextField.text == nil {
            alertController(withTitles: ["OK"], message: "Please enter a valid email and password.", callbackHandler: [nil])
            return false
        }
        
        return true

    }
    
    @IBAction func didTapDismissUpInside(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
