//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

protocol ProfileUserDataDelegate {
    func didSetUserData(userData: UserData)
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var profileImageView: RCCircularImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextView!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var noDataFoundLabel: UILabel!
    @IBOutlet weak var websiteTextView: UITextView!
    
    private var profilePresenter: ProfilePresenter?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Toggle the UI state when view appears to insure that the right elements are hidden.
        toggleEditMode(editing)
        profilePresenter?.attachView(self)
        profilePresenter?.fetchUserData()
//        syncUIWithProfileData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        profilePresenter?.detachView(self)
    }
    
//    func syncUIWithProfileData() {
//        if ProfileDataFetcher.sharedInstance.requiresFetch || ProfileDataFetcher.sharedInstance.userData == nil {
//            ProfileDataFetcher.sharedInstance.fetchAndUpdateData({success, error in
//                if error != nil {
//                    self.alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
//                } else {
//                    // Recursively set the profile data once it has been updated
//                    self.syncUIWithProfileData()
//                }
//            })
//            
//        } else {
//            setUIForUserData(ProfileDataFetcher.sharedInstance.userData!)
//        }
//    }
    
    func setUIForUserData(userData: UserData) {
        dispatch_async(GlobalMainQueue, {
            self.nameLabel.text = userData.name
            self.descriptionTextField.text = userData.bio
            self.profileImageView.userImage = userData.image
            
            if let website = userData.website {
                self.websiteTextView.text = website
            }
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // We check that the user is authenticated and enable the edit button
        // Based on their status.
        editButton.enabled = UserService.sharedInstance().authenticated

    }
    
    @IBAction func didTapEditButtonUpInside(sender: AnyObject) {
        // Switch the editing toggle
        editing = !editing
        // Toggle the editing mode
        toggleEditMode(editing)
    }

    @IBAction func didTapCancelUpInside(sender: AnyObject) {
        if editing {
            toggleEditMode(false)
            
        }
    }
    
    
    func toggleEditMode(editing: Bool) {
        self.editing = editing
        
        editButton.title = editing ? "Save" : "Edit"
        cancelButton.enabled = editing
        nameLabel.hidden = editing
        descriptionTextField.editable = editing
        if editing {
            let borderColor = UIColor.redColor()
            descriptionTextField.layer.borderColor = borderColor.CGColor
        } else {
            descriptionTextField.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    
    func commitChangesToProfile() {
        // TODO: Upload changes to the profile to the server.
        toggleEditMode(false)
    }
}

extension ProfileViewController: ProfileView {

    func didUpdateUserData(didSucceed: Bool, error: NSError?) {
        if error != nil {
            //TODO: Handle the error
        } else {
            //TODO: Reload data.
        }
    }
    func didGetUserDataFromAPI(userData: UserData?, error: NSError?) {
        if error != nil {
            //TODO: Handle the error
        } else {
            self.setUIForUserData(userData!)
        }
    }
}
