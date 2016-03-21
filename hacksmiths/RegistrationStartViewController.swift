//
//  RegisterViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import SwiftyButton

class RegistrationStartViewController: UIViewController {
   
    @IBOutlet weak var firstNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToKeyboardNotification()
        
        setupView()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubsribeToKeyboardNotification()
    }
    
    func setupView() {
        firstNameTextField.becomeFirstResponder()
        navigationController?.toolbar.tintColor = view.backgroundColor
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "goToNext:")
        let xImage = UIImage(named: "x-in-square")
        let leftBarButtonItem = UIBarButtonItem(image: xImage, style: .Plain, target: self, action: "dismissView:")
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    
    func goToNext(sender: AnyObject) {
        let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("LastNameViewController") as! LastNameViewController
        
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension RegistrationStartViewController: UITextFieldDelegate {
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
        
        //view.frame.origin.y = -getKeyboardHeight(notification)
        
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        //view.frame.origin.y = 0
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}
