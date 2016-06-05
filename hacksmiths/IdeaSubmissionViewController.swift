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
    var currentEvent: NextEvent? = nil
    
    /** MARK: Life Cycle Methods
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Loading")
        performViewSetup()
    }
    
    /** Make sure that the view scrolls
     */
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
    
    /** Perform view setup, setting delegate and creating the activity indicator
     */
    func performViewSetup() {
        dispatch_async(GlobalMainQueue, {
            self.setBorderForTextView()
        })
        ideaTitleTextField.delegate = self
        additionalInformationTextField.delegate = self
        ideaDescriptionTextView.clearsOnInsertion = true
    }
    
    /** Set a border around the text view
     */
    func setBorderForTextView() {
        ideaDescriptionTextView.layer.cornerRadius = 5
        ideaDescriptionTextView.layer.borderColor = UIColor.whiteColor().CGColor
        ideaDescriptionTextView.layer.borderWidth = 1
    }
    
    /** Set the view to show the existing submission if there is one.
     */
    func setViewForExistingSubmission(ideaSubmission: ProjectIdeaSubmission) {
        alertController(withTitles: ["Edit", "No Thanks"], message: "Only one submission per person per event.  You can edit your submission if you want!", callbackHandler: [nil, {Void in
            self.cancelSubmission(self)
        }])
        dispatch_async(GlobalMainQueue, {
            self.ideaTitleTextField.text = ideaSubmission.title
            self.ideaDescriptionTextView.text = ideaSubmission.descriptionString
            self.additionalInformationTextField.text = ideaSubmission.additionalInformation
        })
    }
    
    /** When the submission button is tapped, call this method.
     *  Shows the loading indicator and starts the process of submitting the idea to the API.
     *
     *  @param sender: AnyObject, the button that is sending the event
     *  @return None
     */
    @IBAction func didTapSubmissionButton(sender: AnyObject) {
        guard validateSubmission() == true else {
            alertController(withTitles: ["OK"], message: "Please fill in both required text fields before submitting", callbackHandler: [nil])
            return
        }
        
        let title = ideaTitleTextField.text
        let description = ideaDescriptionTextView.text
        let additionalInformation = additionalInformationTextField.text
        print("title: \(title) description: \(description) additionalInfomration: \(additionalInformation)")
        switch submissionStatus {
        case .New:
            ideaSubmissionPresenter.submitIdeaToAPI(title!, description: description!, additionalInformation: additionalInformation, currentEvent: currentEvent!)
        case .Update:
            let newIdea = currentIdea!
            newIdea.descriptionString = description
            newIdea.title = title!
            newIdea.additionalInformation = additionalInformation ?? ""
            ideaSubmissionPresenter.updateIdeaToAPI(newIdea)
        }
    }
    
    /** Validate the submission based on the entered text
     *
     *  @param None
     *  @return Bool - whether the idea submission is valid based on the text of the two required fields.
     */
    private func validateSubmission() -> Bool {
        guard ideaTitleTextField.text != nil && ideaDescriptionTextView.text != nil else {
            return false
        }
        guard ideaTitleTextField.text?.length > 0 && ideaDescriptionTextView.text.length > 0 else {
            return false
        }
        
        return true
    }
    
    /** Cancel the submission when the cancel button is tapped, or if it needs to be cancelled otherwise
     *
     *  @param Sender: AnyObject - the button that sent the event.
     *  @return None
     */
    @IBAction func didTapCancelUpInside(sender: AnyObject) {
        cancelSubmission(self)
    }
}

/** Extension for UI Text field delegate and text view delegate methods
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
    
    /** When touches began in the view, end editing to hide the keyboard.
     *
     *  @param Touches - the touches from the view
     *  @param event - The event sent by the touch
     *  @return None
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    /* Set view origin when keyboard shows */
    func keyboardWillShow(notification: NSNotification) {
        /* Slide the view up when keyboard appears if editing bottom text field, using notifications */
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

/** Extension for Idea Submission View Presenter delegate methods
 */
extension IdeaSubmissionViewController: IdeaSubmissionView {
    
    /** Presenter protocol method that is called after the idea is processed by the API
     *
     *  @param sender - The presenter that called the API
     *  @param didSucceed: Bool - whether the request succeeded or not
     *  @param didFail: Error? - an optional error if the submission failed.
     *  @return None
     */
    func didSubmitIdeaToAPI(sender: IdeaSubmissionPresenter, didSucceed: Bool, didFail: NSError?) {
        finishLoading()
        if didFail != nil {
            alertController(withTitles: ["Ok"], message: (didFail?.localizedDescription)!, callbackHandler: [nil])
        } else if didSucceed == true {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            alertController(withTitles: ["Ok"], message: "An unknown error occured when communicating with the network.  Please try again.", callbackHandler: [nil])
        }
    }
    
    /** When the submission is new, set the status to .New
     *
     *  @param sender - the presenter that sent the message
     *  @return None
     */
    func isNewSubmission(sender: IdeaSubmissionPresenter) {
        finishLoading()
        submissionStatus = .New
    }
    
    func didFindExistingData(sender: IdeaSubmissionPresenter, ideaSubmission: ProjectIdeaSubmission) {
        finishLoading()
        if ideaSubmission.event == currentEvent?.idString {
            submissionStatus = .Update
            currentIdea = ideaSubmission
            setViewForExistingSubmission(ideaSubmission)
        } else {
            submissionStatus = .New
        }
    }
    
    /** Cancel the submission from the presenter
     */
    func cancelSubmission(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /** Unsubscribe from the notifications for keyboard showing / hiding
     */
    func unsubscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /** Subscribe to the notifications for keyboard showing / hiding
     */
    func subscribeToNotifications(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdeaSubmissionViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdeaSubmissionViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
}

/** The text fields for the idea submission.  Maps to the Tag in storyboard
 */
enum IdeaSubmissionTextField: Int {
    case None = 0,
         Description,
         Name,
         AdditionalInformation
    
}

/** Status of the idea submission. Either New or an Update depending on whether an idea is loaded.
 */
enum SubmissionStatus {
    case New, Update
}