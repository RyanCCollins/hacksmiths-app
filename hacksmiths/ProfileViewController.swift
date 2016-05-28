//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData
import TextFieldEffects

protocol ProfileUserDataDelegate {
    func didSetUserData(userData: UserData)
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIToolbarDelegate, SettingsPickerDelegate {
    @IBOutlet weak var haveExperienceTextField: IsaoTextField!
    @IBOutlet weak var wantExperienceTextField: IsaoTextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var profileImageView: RCCircularImageView!
    @IBOutlet weak var profileTextView: UITextView!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var noDataFoundLabel: UILabel!
    @IBOutlet weak var websiteTextField: IsaoTextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var availabilityExplanationTextField: IsaoTextField!

    @IBOutlet weak var formFieldStackView: UIStackView!
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var currentUserData: UserData?
    
    var activityIndicator: IGActivityIndicatorView!
    private var profilePresenter = ProfilePresenter(userProfileService: UserProfileService())
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Toggle the UI state when view appears to insure that the right elements are hidden.
        toggleEditMode(editing)
        setTextFieldDelegate()
        profilePresenter.attachView(self)
        profilePresenter.fetchUserData()
        setScrollView()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // We check that the user is authenticated and enable the edit button
        // Based on their status.
        editButton.enabled = UserService.sharedInstance().authenticated
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Synching")
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /* Hack to get the content scrolling */
    func setScrollView(forEditingMode editing: Bool) {
        scrollView.delegate = self
        scrollView.contentSize.width = view.bounds.width
        if editing {
            scrollView.contentSize.height = 736
        } else {
            scrollView.contentSize.height = view.bounds.height
        }
        
    }

    func setTextFieldDelegate() {
        haveExperienceTextField.delegate = self
        wantExperienceTextField.delegate = self
        availabilityExplanationTextField.delegate = self
        websiteTextField.delegate = self
        profileTextView.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        profilePresenter.detachView(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentSettings" {
            let settingsVC = segue.destinationViewController as! SettingsViewController
            settingsVC.currentUserData = self.currentUserData
            settingsVC.delegate = self
        }
    }
    
    func setUIForCurrentUserData() {
        guard let userData = currentUserData else {
            return
        }
        dispatch_async(GlobalMainQueue, {
            self.nameLabel.text = userData.name
            self.profileTextView.text = userData.bio
            self.profileImageView.userImage = userData.image
            self.setupWebsiteField(userData)
            self.setupMentoringFields(userData)
            self.setupAvailabilityFields(userData)
            self.toggleEditMode(false)
        })
    }
    
    func setupMentoringFields(userData: UserData){
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
    
    func setupAvailabilityFields(userData: UserData) {
        availabilityExplanationTextField.hidden = !userData.isAvailableForEvents
        if let availabilityExplanation = userData.availabilityExplanation {
            availabilityExplanationTextField.text = availabilityExplanation
        }
    }
    
    @IBAction func didTapEditButtonUpInside(sender: AnyObject) {
        if editing {
            commitChangesToProfile()
        }
        toggleEditMode(!editing)
    }

    @IBAction func didTapCancelUpInside(sender: AnyObject) {
        toggleEditMode(!editing)
    }
    
    @IBAction func didTapRefreshUpInside(sender: AnyObject) {
        profilePresenter.fetchUserData()
    }
    
    /* Settings delegate method for updating userData. */
    func didUpdateSettings(userData: UserData) {
        currentUserData = userData
        profilePresenter.submitDataToAPI(currentUserData!)
    }
    
    func toggleEditMode(editing: Bool) {
        self.editing = editing
        
        editButton.title = editing ? "Save" : "Edit"
        cancelButton.enabled = editing
        nameLabel.hidden = editing
        profileTextView.editable = editing
        websiteTextField.hidden = !editing
        helpButton.hidden = !editing
        formFieldStackView.hidden = !editing
        
        if editing {
            profileTextView.becomeFirstResponder()
        }
        
    }
    
    func commitChangesToProfile() {
        if currentUserData != nil {
            profilePresenter.submitDataToAPI(currentUserData!)
        }
    }
    
    @IBAction func handleFormUpdate(sender: IsaoTextField) {
        let textField = ProfileTextFields(rawValue: sender.tag)
        let newValue = sender.text
        if textField != nil {
            switch textField! {
            case .Bio:
                currentUserData?.bio = newValue
            case .Website:
                currentUserData?.website = newValue
            case .HaveExperience:
                currentUserData?.hasExperience = newValue
            case .WantExperience:
                currentUserData?.wantsExperience = newValue
            case .AvailabilityExplanation:
                currentUserData?.availabilityExplanation = newValue
            }
        }
    }
    
    enum ProfileTextFields: Int {
        case Bio = 0, Website,
             HaveExperience, WantExperience,
             AvailabilityExplanation
    }
    
}

/* Profile View Delegate methods */
extension ProfileViewController: ProfileView {
    
    func didUpdateUserData(didSucceed: Bool, error: NSError?) {
        hideLoading()
        if error != nil {
            alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                self.profilePresenter.fetchUserData()
                }])
        } else {
            editing = false
            
        }
    }
    
    func didGetUserDataFromAPI(userData: UserData?, error: NSError?) {
        hideLoading()
        if error != nil {
            alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                self.profilePresenter.fetchUserData()
            }])
        } else {
            self.currentUserData = userData
            self.setUIForCurrentUserData()
        }
    }
    
    func showLoading() {
        guard activityIndicator != nil else {
            return
        }
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        guard activityIndicator != nil else {
            return
        }
        activityIndicator.stopAnimating()
    }
    
    func setActivityIndicator(withMessage message: String?) {
        let activityMessage = message ?? "Loading"
        activityIndicator = IGActivityIndicatorView(inview: self.view, messsage: activityMessage)
    }
    
    func unsubscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
}

extension ProfileViewController: UITextViewDelegate, UITextFieldDelegate {
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
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
        scrollView.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        scrollView.frame.origin.y = 0
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}
