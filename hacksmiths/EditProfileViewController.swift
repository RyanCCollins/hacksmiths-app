//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import TextFieldEffects

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var haveExperienceStackView: UIStackView!
    @IBOutlet weak var eventAvailabilityStackView: UIStackView!
    @IBOutlet weak var wantExperienceStackView: UIStackView!
    @IBOutlet weak var wantExperienceHelpView: UIView!
    @IBOutlet weak var haveExperienceHelpView: UIView!
    @IBOutlet weak var availabilityExplanationHelpView: UIView!
    var userData: UserData!
    var delegate: EditProfileDelegate?
    @IBOutlet weak var bioTextField: IsaoTextField!
    @IBOutlet weak var haveExperienceTextField: IsaoTextField!
    @IBOutlet weak var wantExperienceTextField: IsaoTextField!
    @IBOutlet weak var websiteTextField: IsaoTextField!
    @IBOutlet weak var availabilityExplanationTextField: IsaoTextField!
    private var formChanged = false
    private var presenter = EditProfilePresenter()
    private var activityIndicator: IGActivityIndicatorView!
    
    /* Edge case where it's actually better to use a global for a value outside the scope*/
    private var helpLabelText = ""
    
    /** MARK: Life cycle methods
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        setTextFieldDelegates()
        if let currentUserData = userData {
            setupMentoringFields(currentUserData)
            setupAvailabilityFields(currentUserData)
            setupBioField(currentUserData)
            setupWebsiteField(currentUserData)
        }
        activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Saving")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.detachView(self)
    }
    
    private func setTextFieldDelegates() {
        bioTextField.delegate = self
        haveExperienceTextField.delegate = self
        wantExperienceTextField.delegate = self
        availabilityExplanationTextField.delegate = self
        websiteTextField.delegate = self
    }
    
    private func setupMentoringFields(userData: UserData){
        wantExperienceStackView.hidden = !userData.needsAMentor
        haveExperienceStackView.hidden = !userData.isAvailableAsAMentor
        eventAvailabilityStackView.hidden = !userData.isAvailableForEvents
        
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
    
    private func setupWebsiteField(userData: UserData) {
        if let website = userData.website {
            websiteTextField.text = website
        }
    }
    
    private func setupBioField(userData: UserData) {
        if let bio = userData.bio {
            bioTextField.text = bio
        }
    }
    
    /** Setup the availability fields to match the user data
     */
    private func setupAvailabilityFields(userData: UserData) {
        availabilityExplanationTextField.hidden = !userData.isAvailableForEvents
        availabilityExplanationHelpView.hidden = !userData.isAvailableForEvents
        
        if let availabilityExplanation = userData.availabilityExplanation {
            availabilityExplanationTextField.text = availabilityExplanation
        }
    }
    
    @IBAction func didTapHelpButtonUpInside(sender: AnyObject) {
        let textField = ProfileTextFields(rawValue: sender.tag)
        helpLabelText = helpText(forField: textField!)
        performSegueWithIdentifier("ShowProfileHelpPopover", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowProfileHelpPopover" {
            let profileHelpViewController = segue.destinationViewController as! ProfileHelpPopoverViewController
            profileHelpViewController.helpText = helpLabelText
            profileHelpViewController.modalPresentationStyle = .Popover
            profileHelpViewController.popoverPresentationController!.delegate = self
            let popover = profileHelpViewController.popoverPresentationController
            popover!.sourceView = sender as! UIButton
            popover!.sourceRect = CGRectMake(0, 0, sender!.bounds.width, sender!.bounds.height)
        }
    }
    
    /** Handle updating the form when changed, setting the userData and updating
     *
     *  @param sender - the text field that sent the action, which maps via the tag to a textField enum value
     *  @return None
     */
    @IBAction private func handleFormUpdate(sender: IsaoTextField) {
        formChanged = true
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
    
    /** Handle closing / dismissing the form.
     */
    @IBAction func didTapCloseButtonUpInside(sender: AnyObject) {
        userData = nil
        zeroOutTextFields()
        formChanged = false
        handleDismissForm(self)
    }
    
    func zeroOutTextFields(){
        bioTextField.text = nil
        websiteTextField.text = nil
        haveExperienceTextField.text = nil
        wantExperienceTextField.text = nil
        availabilityExplanationTextField.text = nil
    }
    
    /** Handle saving the form when the button is tapped
     *
     *  @param sender: AnyObject - the sender who sent the message
     *  @return None
     */
    @IBAction func handleSaveForm(sender: AnyObject) {
        if formChanged {
            delegate?.didSubmitEditedData(userData!)
        }
        handleDismissForm(self)
    }
    
    /** Handle dismissing the form
     */
    func handleDismissForm(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /** Profile text fields - matches the tag for profile text fields in storyboard.
     */
    private enum ProfileTextFields: Int {
        case Bio = 1, Website,
        HaveExperience, WantExperience,
        AvailabilityExplanation
    }
    
    /** helpText - sets the help text for each field
     *
     *  @param field: ProfileTextFields - the text field from the matching enumeration
     *  @return String - the help text for the field
     */
    private func helpText(forField field: ProfileTextFields) -> String {
        switch field {
        case .HaveExperience:
            return "You checked off that you are available as a mentor.  What experience do you have to offer?"
        case .WantExperience:
            return "You checked off that you are looking for a mentor.  What experience are you looking for?"
        case .AvailabilityExplanation:
            return "You checked off that you are available for events.  Write a brief description of your availability."
        default:
            return ""
        }
    }
}

extension EditProfileViewController: EditProfileView {
    /** Standard Show and Hide loading
     *  Not being used in current iteration, but since we are following
     *  The presenter pattern for the rest of the app, this is set up to
     *  deal with growing complexity
     */
    func showLoading() {
        dispatch_async(GlobalMainQueue, {
            self.activityIndicator.startAnimating()
        })
        
    }
    func hideLoading() {
        dispatch_async(GlobalMainQueue, {
            self.activityIndicator.stopAnimating()
        })
    }
    
    func unsubscribeToNotifications(sender: EditProfilePresenter) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToNotifications(sender: EditProfilePresenter) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
}

/** Show popover view for help text
 */
extension EditProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

extension EditProfileViewController: UITextFieldDelegate {

    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let field = ProfileTextFields(rawValue: textField.tag)
        switch field! {
        case .Bio:
            websiteTextField.becomeFirstResponder()
        case .Website:
            /* Walk through the remaining text fields, determining if they are active
             * and set the next one as the active text field if so.
             */
            if haveExperienceTextField.hidden == false {
                haveExperienceTextField.becomeFirstResponder()
            } else if wantExperienceTextField.hidden == false {
                wantExperienceTextField.becomeFirstResponder()
            } else if availabilityExplanationTextField.hidden == false {
                availabilityExplanationTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        case .HaveExperience:
            if wantExperienceTextField.hidden == false {
                wantExperienceTextField.becomeFirstResponder()
            } else if availabilityExplanationTextField.hidden == false {
                availabilityExplanationTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        case .WantExperience:
            if availabilityExplanationTextField.hidden == false {
                availabilityExplanationTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    /* Slide the view up when keyboard appears if editing bottom text field, using notifications */
    func keyboardWillShow(notification: NSNotification) {
        if wantExperienceTextField.isFirstResponder() || availabilityExplanationTextField.isFirstResponder() {
            contentView.frame.origin.y = -getKeyboardHeight(notification)
            /* Make the view scroll to allow easier editing. */
            scrollView.contentSize.height = 700
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        contentView.frame.origin.y = 0
        scrollView.contentSize.height = view.frame.height
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}

