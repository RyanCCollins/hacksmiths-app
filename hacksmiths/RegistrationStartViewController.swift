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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    
    func setupView() {
        // Make sure that the textfield becomes first responder right away
        firstNameTextField.becomeFirstResponder()
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor();
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "goToNext:")
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        let xImage = UIImage(named: "x-in-square")
        let leftBarButtonItem = UIBarButtonItem(image: xImage, style: .Plain, target: self, action: "dismissView:")
        leftBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    
    func goToNext(sender: AnyObject) {
        
        if isValid() == true {
            let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("LastNameViewController") as! LastNameViewController
            
            navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            
        }
        

    }
    
    func isValid() -> Bool {
        if firstNameTextField.text == nil {
            return false
        } else {
            return true
        }
    }
    
    func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


