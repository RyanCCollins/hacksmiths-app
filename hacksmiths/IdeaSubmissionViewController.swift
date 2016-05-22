//
//  IdeaLandingViewController
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class IdeaSubmissionViewController: UIViewController {
    
    var ideaSubmissionPresenter: IdeaSubmissionPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ideaSubmissionPresenter?.attachView(self)
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
        return keyboardSize.CGRectValue().height
    }
}

extension IdeaSubmissionViewController: IdeaSubmissionView {

    func submitIdeaToAPI(sender: IdeaSubmissionPresenter, idea: ProjectIdeaJSON) {
        
    }
    
    func cancelSubmission(sender: AnyObject) {
        print("Here")
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
}
