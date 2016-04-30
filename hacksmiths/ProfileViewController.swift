//
//  EditProfileViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextView!

    @IBOutlet weak var profilePhotoViewOverlay: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var noDataFoundLabel: UILabel!
    
    var imageToUpload: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMostUpToDateDataFromAPI()
    }
    
    func getMostUpToDateDataFromAPI() {
        
        // If the user is authenticated then create a request to get the profile data:
        if UserDefaults.sharedInstance().authenticated == true {
            let userID = UserDefaults.sharedInstance().userId
            
            // Protect against the UserID being nil, for some reason
            guard userID != nil || userID != "" else {
                return
            }
            
            let dictionary: [String : AnyObject] = [ "user" : userID! ]
            print(userID!)
            HacksmithsAPIClient.sharedInstance().getUserDataFromAPI(dictionary, completionHandler: {success, error in
                
                if error != nil {
                    self.alertController(withTitles: ["Ok", "Retry"], message: error!.localizedDescription, callbackHandler: [nil,{Void in
                            self.getMostUpToDateDataFromAPI()
                    }])
                } else {
                    
                    self.performUserFetch()
                    self.updateUIForUser()
                }
            })
        }
    }
    
    func updateUIForUser() {
        if let user = fetchedResultsController.fetchedObjects![0] as? UserData {
            nameLabel.text = user.name
            descriptionTextField.text = user.bio
            profileImageView.image = user.image
        }
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
        
        descriptionTextField.editable = editing
        
    }
    
    func commitChangesToProfile() {
        // TODO: Upload changes to the profile to the server.
        toggleEditMode(false)
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "dateUpdated", ascending: false)
        let userDataFetch = NSFetchRequest(entityName: "UserData")
        userDataFetch.sortDescriptors = [sortPriority]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: userDataFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    func performUserFetch() {
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            self.alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                self.performUserFetch()
                }])
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}
