//
//  PasswordViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    func setupView() {
        passwordTextField.becomeFirstResponder()
        let backwardArrow = UIImage(named: "backward-arrow")
        configureNavigationBar("Next", barButtonImage: backwardArrow!)
 
    }
    
    func configureNavigationBar(title: String, barButtonImage: UIImage) {
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.toolbar.barTintColor = view.backgroundColor
        
        let rightBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: "submitForm")

        let backButton = UIBarButtonItem(image: barButtonImage, style: .Plain, target: self, action: "goToLastView:")
        // Set the color and then apply the items
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        backButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.setLeftBarButtonItem(backButton, animated: true)
    }
    
    
    func goToNextView(sender: AnyObject) {
        let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("EmailViewController") as! EmailViewController
        
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func goToLastView(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Check
    func dataIsValid()-> Bool {
        if RegistrationData.sharedInstanced().isComplete() == true {
            return true
        }
        return false
    }
    
    func submitForm() {
        if dataIsValid() {
            let body: [String : AnyObject] = [HacksmithsAPIClient.Keys.Email : RegistrationData.sharedInstanced().email!,
                HacksmithsAPIClient.Keys.Password : RegistrationData.sharedInstanced().password!,
                HacksmithsAPIClient.Keys.FirstName : RegistrationData.sharedInstanced().nameFirst!,
                HacksmithsAPIClient.Keys.LastName : RegistrationData.sharedInstanced().nameLast!
            ]
            HacksmithsAPIClient.sharedInstance().registerWithEmail(body, completionHandler: {success, error in
                
            })
        }
    }
}
