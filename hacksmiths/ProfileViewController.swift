//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var tapToEditPhotoLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextView!

    @IBOutlet weak var profilePhotoViewOverlay: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var noDataFoundLabel: UILabel!
    
    @IBOutlet weak var githubLabel: UILabel!
    
    var imageToUpload: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Toggle the UI state when view appears to insure that the right elements are hidden.
        toggleEditMode(editing)
        
        // Set the profile image view image to the avatar missing if there is no photo.
        if profileImageView.image == nil {
            profileImageView.image = UIImage(named: "avatar-missing")
        }
    }
    
    func addTouchRecognizer() {
        let fingerTouchGestureRecognizer = UIGestureRecognizer(target: profilePhotoViewOverlay, action: "didTapEditPhoto:")
        profilePhotoViewOverlay.addGestureRecognizer(fingerTouchGestureRecognizer)
    }
    
    func setUIDefaults() {

        
    }
    
    func didTapEditPhoto(sender: UIGestureRecognizer) {
        if sender.numberOfTouches() == 1 && editing == true {
            editProfileImagePhoto()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // We check that the user is authenticated and enable the edit button
        // Based on their status.
        editButton.enabled = UserDefaults.sharedInstance().authenticated

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
        nameTextField.hidden = !editing

        profilePhotoViewOverlay.hidden = !editing
        cameraButton.hidden = !editing
        tapToEditPhotoLabel.hidden = !editing
        
        descriptionTextField.editable = editing
        descriptionTextField.editable = editing
        
        profilePhotoViewOverlay.hidden = !editing
        cameraButton.hidden = !editing
        tapToEditPhotoLabel.hidden = !editing
    }
    
    func editProfileImagePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func commitChangesToProfile() {
        // TODO: Upload changes to the profile to the server.
        toggleEditMode(false)
    }
    
    
}

// Extension for profile view controller delegate methods
extension ProfileViewController {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: {
            // Set image to upload so that we can handle uploading it later.
            self.profileImageView.image = image
            self.imageToUpload = image
        
        })
    }
    
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if editing {
            view.endEditing(true)
        }
    }
}