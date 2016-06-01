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
    var formChanged = false
    private var presenter = EditProfilePresenter()
    /* Edge case where it's actually better to use a global for a value outside the scope*/
    private var helpLabelText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        if let currentUserData = userData {
            setupMentoringFields(currentUserData)
            setupAvailabilityFields(currentUserData)
            setupBioField(currentUserData)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.detachView(self)
    }
    
    private func setupMentoringFields(userData: UserData){
        haveExperienceTextField.hidden = !userData.isAvailableAsAMentor
        wantExperienceTextField.hidden = !userData.needsAMentor
        haveExperienceHelpView.hidden = !userData.isAvailableAsAMentor
        wantExperienceHelpView.hidden = !userData.needsAMentor
        
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
        }
    }
    
    @IBAction private func handleFormUpdate(sender: IsaoTextField) {
        print("Calling form changed")
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
    
    @IBAction func didTapCloseButtonUpInside(sender: AnyObject) {
        handleDismissForm(self)
    }
    
    @IBAction func handleSaveForm(sender: AnyObject) {
        if formChanged {
            delegate?.didSubmitEditedData(userData!)
        } else {
            handleDismissForm(self)
        }
    }
    
    func handleDismissForm(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private enum ProfileTextFields: Int {
        case Bio = 1, Website,
        HaveExperience, WantExperience,
        AvailabilityExplanation
    }
    
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
    
}

/** Show popover view for help text
 */
extension EditProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}



