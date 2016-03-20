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
        subscribeToKeyboardNotification()
    }

    override func viewWillDisappear(animated: Bool) {
        unsubsribeToKeyboardNotification()
    }
    
    @IBAction func didTapSignUpUpInside(sender: AnyObject) {
        submitForm()
    }
    
    func submitForm() {
        if formIsValid() {
            let body: [String : AnyObject] = [HacksmithsAPIClient.Keys.Email : emailTextField.text!,
                HacksmithsAPIClient.Keys.Password : passwordTextField.text!,
                HacksmithsAPIClient.Keys.FirstName : firstNameTextField.text!,
                HacksmithsAPIClient.Keys.LastName : lastNameTextField.text!
            ]
            HacksmithsAPIClient.sharedInstance().registerWithEmail(body, completionHandler: {success, error in
                
            })
        }
    }
    
    func formIsValid() -> Bool {
        // Check to see that all fields are filled in.  If not, then alert the user,
        // Note that no other checking is done here.  We will have to check to see that the fields are indeed valid.
        
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

extension RegisterViewController: UITextFieldDelegate {
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
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* Slide the view up when keyboard appears, using notifications */
        
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
