//
//  RegisterViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import TextFieldEffects

class RegistrationStartViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var textField: IsaoTextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    
    }
    
    
    func setupView() {
        // Make sure that the textfield becomes first responder right away
    
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
    
    func validateTextEntry(sender: UITextField) {
        if sender.text!.length > 0 {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }

    
    func goToNext(sender: AnyObject) {
        
        if isValid() == true {
            let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("LastNameViewController") as! LastNameViewController
            
            navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            
        }
        

    }
    
    func isValid() -> Bool {
        if textField.text == nil {
            return false
        } else {
            return true
        }
    }
    
    func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension RegistrationStartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == nil || textField.text == "" {

            return false
        }
        // Go to the next screen
        goToNext(self)
        return true
    }
    
}

class RegistrationFormViewController: UIViewController {
    
    var textField: UITextField?
    
    convenience init() {
        self.init(textField: nil)
    }
    
    init(textField: UITextField?) {
        self.textField = textField
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func configureView() {
        
    }
    
    func setFirstResponder(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    
    
}


