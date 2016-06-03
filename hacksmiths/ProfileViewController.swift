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
/** Profile View Controller -  Controls the profile view for users when logged into Hacksmiths
 *
 */
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
    
    /** MARK: Life cycle methods
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        profilePresenter.attachView(self)
        profilePresenter.fetchCachedData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // We check that the user is authenticated and enable the edit button based on their status.
        editButton.enabled = UserService.sharedInstance().authenticated
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        profilePresenter.detachView(self)
    }
    
    /** Prepare for segue to the present settings
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentSettings" {
            let settingsVC = segue.destinationViewController as! SettingsViewController
            settingsVC.currentUserData = self.currentUserData
            settingsVC.delegate = self
        }
    }
    
    /** Set the UI for the currently logged in user
     *
     *  @params - userData: UserData - the data for the current user
     *  @return - None
     */
    func setUIForCurrentUserData(userData: UserData) {
        dispatch_async(GlobalMainQueue, {
            self.nameLabel.text = userData.name
            self.profileTextView.text = userData.bio
            self.profileImageView.userImage = userData.image
            if userData.image != nil {
                self.profileImageView.setImage()
            }
        })
    }
    
    /** When edit button is tapped, present the Edit Profile View Controller
     *
     *  @params - sender: AnyObject - the button tapped from the view
     */
    @IBAction func didTapEditButtonUpInside(sender: AnyObject) {
        let editProfileViewController = storyboard?.instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
        editProfileViewController.delegate = self
        editProfileViewController.userData = currentUserData
        presentViewController(editProfileViewController, animated: true, completion: nil)
    }
    
    /** Did tap refresh - refresh the data from the API through the presenter when button is tapped
     *
     *  @params sender: AnyObject - the button that was clicked to send the action
     */
    @IBAction func didTapRefreshUpInside(sender: AnyObject) {
        profilePresenter.fetchUserDataFromAPI()
    }
    
    /** Settings delegate method for updating userData.
     *
     *  @params - userData: UserData - the user's updated data
     *  @return - None
     */
    func didUpdateSettings(userData: UserData) {
        currentUserData = userData
        profilePresenter.submitDataToAPI(currentUserData!)
    }
}

/** Profile VC Extension for Profile View Protocol
 *  Follows the MVP design pattern
 */
extension ProfileViewController: ProfileView {
    /** Did update user data, protocol method called when the Promise from updating
     *  The data in the API has resolved.
     */
    func didUpdateUserData(didSucceed: Bool, error: NSError?) {
        finishLoading()
        if error != nil {
            alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                self.profilePresenter.fetchUserDataFromAPI()
                }])
        } else {
            editing = false
        }
    }
    
    /** Called when the cached user data is loaded or not loaded with an error
     *
     *  @param UserData the user data loaded.
     *  @param Error: NSError, an optional error returned from the core data call
     *  @return None
     */
    func didLoadCachedUserData(userData: UserData?, error: NSError?) {
        if error != nil {
            /* An error occured during fetching */
            alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                self.profilePresenter.fetchUserDataFromAPI()
            }])
        } else if userData != nil {
            currentUserData = userData
            setUIForCurrentUserData(userData!)
        } else {
            startLoading()
            profilePresenter.fetchUserDataFromAPI()
        }
    }
    
    /** Did get user data from the API - Presenter protocol method
     *
     *  @param userData: UserData - optional user data, core data model for the user
     *  @param error: NSError - optional error if one is thrown during call to API
     *  @return None
     */
    func didGetUserDataFromAPI(userData: UserData?, error: NSError?) {
        finishLoading()
        if error != nil {
            alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in
                self.profilePresenter.fetchUserDataFromAPI()
            }])
        } else if userData != nil {
            self.currentUserData = userData
            self.setUIForCurrentUserData(userData!)
        }
    }
    
    /** Show the loading indicator in the view
     */
    func startLoading() {
        dispatch_async(GlobalMainQueue, {
            self.activityIndicator.startAnimating()
        })
    }
    
    /** Hide the activity indicator in the view
     */
    func finishLoading() {
        dispatch_async(GlobalMainQueue, {
            self.activityIndicator.stopAnimating()
        })
    }
    
    /** Protocol method to setup the activity indicator when attaching the view
     *
     * @param - Message: String - a message to be shown in the indicator view.  Defailts to "Loading"
     */
    func setActivityIndicator(withMessage message: String?) {
        let activityMessage = message ?? ""
        activityIndicator = IGActivityIndicatorView(inview: self.view, messsage: activityMessage)
        activityIndicator.addTapHandler({
            self.finishLoading()
        })
    }
}


/** Handle submission of data through the edit form view controller. 
 */
extension ProfileViewController: EditProfileDelegate {
    func didSubmitEditedData(userData: UserData) {
        didUpdateSettings(userData)
    }
    
    /** Limit this view from auto rotating to avoid UI issues
     */
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}