//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    var userData: UserData?
    var delegate: EditProfileDelegate?
    @IBOutlet weak var bioTextField: RCNextTextField!
    @IBOutlet weak var haveExperienceTextField: RCNextTextField!
    @IBOutlet weak var wantExperienceTextField: RCNextTextField!
    @IBOutlet weak var websiteTextField: RCNextTextField!
    @IBOutlet weak var availabilityExplanationTextField: RCNextTextField!
    private var presenter = EditProfilePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegates()
        presenter.attachView(self)
        
        if let currentUserData = userData {
            setupMentoringFields(currentUserData)
            setupAvailabilityFields(currentUserData)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.detachView(self)
    }
    
    private func setTextFieldDelegates() {
        haveExperienceTextField.delegate = self
        wantExperienceTextField.delegate = self
        websiteTextField.delegate = self
        availabilityExplanationTextField.delegate = self
    }
    
    private func setupMentoringFields(userData: UserData){
        haveExperienceTextField.hidden = !userData.isAvailableAsAMentor
        wantExperienceTextField.hidden = !userData.needsAMentor
        
        /* Set the text for mentoring fields */
        if userData.isAvailableAsAMentor {
            if let haveExperienceText = userData.hasExperience {
                haveExperienceTextField.text = haveExperienceText
            }
        }
        if userData.needsAMentor {
            if let wantExperienceText = userData.wantsExperience {
                wantExperienceTextField.text = wantExperienceText
            }
        }
    }
    
    func setupWebsiteField(userData: UserData) {
        if let website = userData.website {
            websiteTextField.text = website
        }
    }
    
    private func setupAvailabilityFields(userData: UserData) {
        availabilityExplanationTextField.hidden = !userData.isAvailableForEvents
        if let availabilityExplanation = userData.availabilityExplanation {
            availabilityExplanationTextField.text = availabilityExplanation
        }
    }
    
    
    @IBAction private func handleFormUpdate(sender: RCNextTextField) {
        let textField = ProfileTextFields(rawValue: sender.tag)
        let newValue = sender.text
        if textField != nil {
            switch textField! {
            case .Bio:
                userData!.bio = newValue
            case .Website:
                userData!.website = newValue
            case .HaveExperience:
                userData!.hasExperience = newValue
            case .WantExperience:
                userData!.wantsExperience = newValue
            case .AvailabilityExplanation:
                userData!.availabilityExplanation = newValue
            }
        }
    }
    
    private enum ProfileTextFields: Int {
        case Bio = 0, Website,
        HaveExperience, WantExperience,
        AvailabilityExplanation
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let rcTextField = textField as! RCNextTextField
        if rcTextField.nextTextField != nil {
            rcTextField.nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
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
        return keyboardSize.CGRectValue().height -  50
    }
    
}

extension EditProfileViewController: EditProfileView {
    func unsubscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
}



