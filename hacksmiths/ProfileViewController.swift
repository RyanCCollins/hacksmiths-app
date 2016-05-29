//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol ProfileUserDataDelegate {
    func didSetUserData(userData: UserData)
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIToolbarDelegate, SettingsPickerDelegate {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var profileImageView: RCCircularImageView!
    @IBOutlet weak var profileTextView: UITextView!

    @IBOutlet weak var noDataFoundLabel: UILabel!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var currentUserData: UserData?
    
    var activityIndicator: IGActivityIndicatorView!
    private var profilePresenter = ProfilePresenter(userProfileService: UserProfileService())
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        profilePresenter.attachView(self)
        profilePresenter.fetchUserData()
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
            if userData.image != nil {
                self.profileImageView.setImage()
            }
        })
    }
    
    @IBAction func didTapEditButtonUpInside(sender: AnyObject) {
        let editProfileViewController = storyboard?.instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
        editProfileViewController.delegate = self
        editProfileViewController.userData = currentUserData
        presentViewController(editProfileViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapRefreshUpInside(sender: AnyObject) {
        profilePresenter.fetchUserData()
    }
    
    /* Settings delegate method for updating userData. */
    func didUpdateSettings(userData: UserData) {
        currentUserData = userData
        profilePresenter.submitDataToAPI(currentUserData!)
    }
    
    func commitChangesToProfile() {
        if currentUserData != nil {
            profilePresenter.submitDataToAPI(currentUserData!)
        }
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

}


/* Handle submission of data through the edit form view controller. */
extension ProfileViewController: EditProfileDelegate {
    func didSubmitEditedData(userData: UserData) {
        profilePresenter.submitDataToAPI(userData)
    }
}