//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var twitterUsernameTextField: UITextField!
    @IBOutlet weak var githubUsernameTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var githubLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        descriptionLabel.hidden = editing
        descriptionTextField.hidden = !editing
        twitterLabel.hidden = editing
        twitterUsernameTextField.hidden = !editing
        
    }
    
    func updateProfile() {
        
    }
    

}
