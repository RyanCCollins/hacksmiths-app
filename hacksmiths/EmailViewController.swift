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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    func setupView() {
        emailTextField.becomeFirstResponder()
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.toolbar.barTintColor = view.backgroundColor
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "goToNextView:")
        let backwardArrow = UIImage(named: "backward-arrow")
        let backButton = UIBarButtonItem(image: backwardArrow, style: .Plain, target: self, action: "goToLastView:")
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.setLeftBarButtonItem(backButton, animated: true)
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        backButton.tintColor = UIColor.whiteColor()    }
    
    
    func goToNextView(sender: AnyObject) {
        let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("PasswordViewController") as! PasswordViewController
        
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func goToLastView(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
