//
//  EmailViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //subscribeToKeyboardNotification()
        
        setupView()
        
    }
    override func viewWillDisappear(animated: Bool) {
        //unsubsribeToKeyboardNotification()
    }
    
    func setupView() {
        emailTextField.becomeFirstResponder()
        
        navigationController?.toolbar.tintColor = view.backgroundColor
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "goToNextView:")
        let backwardArrow = UIImage(named: "backward-arrow")
        let backButton = UIBarButtonItem(image: backwardArrow, style: .Plain, target: self, action: "goBackToLastView:")
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.setLeftBarButtonItem(backButton, animated: true)
    }
    
    
    func goToNextView(sender: AnyObject) {
        let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("PasswordViewController") as! PasswordViewController
        
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func goToLastView(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
