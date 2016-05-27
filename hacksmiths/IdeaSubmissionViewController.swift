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
    var activityIndicator: IGActivityIndicatorView!
    
    var ideaSubmissionPresenter: IdeaSubmissionPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ideaSubmissionPresenter?.attachView(self)
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
    
    @IBAction func didTapSubmissionButton(sender: AnyObject) {
        if validateSubmission() == true {
            let additionalInformationText = additionalInformationTextField.text ?? ""
            let ideaSubmission: JsonDict = [
                "title": ideaTitleTextField.text!,
                "description": ideaDescriptionTextView.text,
                "additionalInformation" : additionalInformationText
            ]
            ideaSubmissionPresenter?.submitIdeaToAPI(ideaSubmission)
        } else {
            alertController(withTitles: ["OK"], message: "Please fill in both text fields before submitting", callbackHandler: [nil])
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ideaSubmissionPresenter?.attachView(self)
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ideaSubmissionPresenter?.detachView(self)
    }
}

extension IdeaSubmissionViewController: UITextViewDelegate, UITextFieldDelegate {
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        contentView.frame.origin.y = -getKeyboardHeight(notification)
        let visibleRect = self.view.frame
        
        
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

extension IdeaSubmissionViewController: IdeaSubmissionView {
    
    func didSubmitIdeaToAPI(sender: IdeaSubmissionPresenter, didSucceed: Bool, didFail: NSError?) {
        if didFail != nil {
            alertController(withTitles: ["Ok"], message: (didFail?.localizedDescription)!, callbackHandler: [nil])
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
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
