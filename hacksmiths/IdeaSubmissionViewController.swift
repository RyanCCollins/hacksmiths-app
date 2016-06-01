//
//  IdeaLandingViewController
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import TextFieldEffects

class IdeaSubmissionViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ideaDescriptionTextView: UITextView!
    @IBOutlet weak var ideaTitleTextField: IsaoTextField!
    @IBOutlet weak var additionalInformationTextField: IsaoTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var activityIndicator: IGActivityIndicatorView!
    var ideaSubmissionPresenter = IdeaSubmissionPresenter(projectIdeaService: ProjectIdeaService())
    var submissionStatus: SubmissionStatus = .New
    var currentIdea: ProjectIdeaSubmission? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ideaSubmissionPresenter.attachView(self)
        performViewSetup()
        ideaSubmissionPresenter.findExistingIdea()
        if currentIdea != nil {
            submissionStatus = .Update
        } else {
            submissionStatus = .New
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize.height = 700
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ideaSubmissionPresenter.attachView(self)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ideaSubmissionPresenter.detachView(self)
    }
    
    func performViewSetup() {
        setBorderForTextView()
        ideaTitleTextField.delegate = self
        additionalInformationTextField.delegate = self
        ideaDescriptionTextView.clearsOnInsertion = true
        activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Loading")
    }
    
    func setBorderForTextView() {
        ideaDescriptionTextView.layer.cornerRadius = 5
        ideaDescriptionTextView.layer.borderColor = UIColor.whiteColor().CGColor
        ideaDescriptionTextView.layer.borderWidth = 1
    }
    
    func setViewForExistingSubmission(ideaSubmission: ProjectIdeaSubmission) {
        ideaTitleTextField.text = ideaSubmission.title
        ideaDescriptionTextView.text = ideaSubmission.descriptionString
        additionalInformationTextField.text = ideaSubmission.additionalInformation
    }
    
    @IBAction func didTapSubmissionButton(sender: AnyObject) {
        guard validateSubmission() == true else {
            alertController(withTitles: ["OK"], message: "Please fill in both required text fields before submitting", callbackHandler: [nil])
            return
        }
        /* Show the loading indicator */
        showLoading()
        
        let title = ideaTitleTextField.text
        let description = ideaDescriptionTextView.text
        let additionalInformation = additionalInformationTextField.text
        
        switch submissionStatus {
        case .New:
            ideaSubmissionPresenter.submitIdeaToAPI(title!, description: description!, additionalInformation: additionalInformation)
        case .Update:
            let newIdea = currentIdea!
            newIdea.descriptionString = description
            newIdea.title = title!
            newIdea.additionalInformation = additionalInformation ?? ""
            ideaSubmissionPresenter.updateIdeaToAPI(newIdea)
        }
    }
    
    private func validateSubmission() -> Bool {
        guard ideaTitleTextField.text != nil && ideaDescriptionTextView.text != nil else {
            return false
        }
        return true
    }
    
    @IBAction func didTapCancelUpInside(sender: AnyObject) {
        cancelSubmission(self)
    }
}

/*
 * Extension for UI Text field delegate and text view delegate methods
 */
extension IdeaSubmissionViewController: UITextViewDelegate, UITextFieldDelegate {
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let field = IdeaSubmissionTextField(rawValue: textField.tag)
        switch field! {
        case .Description:
            ideaTitleTextField.becomeFirstResponder()
        case .Name:
            additionalInformationTextField.becomeFirstResponder()
        case .AdditionalInformation:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears if editing bottom text field, using notifications */
        if additionalInformationTextField.editing {
            contentView.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        contentView.frame.origin.y = 0
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}

/*
 * Extension for Idea Submission View Presenter delegate methods
 */
extension IdeaSubmissionViewController: IdeaSubmissionView {
    
    func didSubmitIdeaToAPI(sender: IdeaSubmissionPresenter, didSucceed: Bool, didFail: NSError?) {
        hideLoading()
        if didFail != nil {
            alertController(withTitles: ["Ok"], message: (didFail?.localizedDescription)!, callbackHandler: [nil])
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func isNewSubmission(sender: IdeaSubmissionPresenter) {
        submissionStatus = .New
    }
    
    func didFindExistingData(sender: IdeaSubmissionPresenter, ideaSubmission: ProjectIdeaSubmission) {
        submissionStatus = .Update
        currentIdea = ideaSubmission
        setViewForExistingSubmission(ideaSubmission)
    }
    
    func cancelSubmission(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unsubscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdeaSubmissionViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdeaSubmissionViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func showLoading() {
        activityIndicator.showLoading()
    }
    
    func hideLoading() {
        activityIndicator.hideLoading()
    }
}

enum IdeaSubmissionTextField: Int {
    case None = 0,
         Description,
         Name,
         AdditionalInformation
    
}

enum SubmissionStatus {
    case New, Update
}