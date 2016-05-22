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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ideaSubmissionPresenter?.attachView(self)
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ideaSubmissionPresenter?.detachView(self)
        unsubsribeToKeyboardNotification()
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
        /* Enable save button if fields are filled out  */
        
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
    func submitNewIdea(sender: IdeaSubmissionPresenter, idea: ProjectIdeaJSON) {
        
    }
    
    func cancelSubmission(sender: IdeaSubmissionPresenter) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToNotifications(sender: IdeaSubmissionPresenter) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(sender: IdeaSubmissionPresenter){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}
