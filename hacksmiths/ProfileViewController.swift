//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate {
    
    
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
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func addTouchRecognizer() {
        let fingerTouchGestureRecognizer = UIGestureRecognizer(target: profilePhotoViewOverlay, action: "didTapEditPhoto:")
        profilePhotoViewOverlay.addGestureRecognizer(fingerTouchGestureRecognizer)
    }
    
    func hideUIElements() {
        profilePhotoViewOverlay.hidden = true
        cameraButton.hidden = true
        tapToEditPhotoLabel.hidden = true
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
        editButton.enabled = UserData.sharedInstance().authenticated

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

        descriptionTextField.hidden = !editing
        
    }
    
    func editProfileImagePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
    }
    
    

}
