//
//  PersonViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/9/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {
    var person: Person? = nil
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personDescriptionLabel: UITextView!
    @IBOutlet weak var personTwitterLabel: UILabel!
    @IBOutlet weak var personGithubLabel: UILabel!
    
    @IBOutlet weak var noDataFoundLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewObjectsHidden(true)
        makeImageViewCircular()
        configurePersonView()
        
    }
    
    func setViewObjectsHidden(hidden: Bool) {

        personNameLabel.hidden = hidden
        personDescriptionLabel.hidden = hidden
        personImageView.hidden = hidden
        noDataFoundLabel.hidden = !hidden
    }
    
    func makeImageViewCircular() {
        personImageView?.layer.cornerRadius = personImageView!.frame.size.width / 2
        personImageView?.clipsToBounds = true
        personImageView?.layer.borderWidth = 3.0
        personImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func configurePersonView() {
        if person != nil {
            if person!.image != nil {
                personImageView.image = person!.image
            } else {
                // Set the default image view image to show a missing image
                personImageView.image = UIImage(named: "avatar-missing")
            }
            
            personNameLabel.text = person!.firstName + " " + person!.lastName
            personDescriptionLabel.text = person!.bio
            
            setViewObjectsHidden(false)
            
            if let twitterUsername = person!.twitterUsername {
                personTwitterLabel.text = twitterUsername
                personTwitterLabel.hidden = false
            }
            
            if let githubUserName = person!.githubUsername {
                personGithubLabel.text = githubUserName
                personGithubLabel.hidden = false
            }
        } else {
            
            setViewObjectsHidden(true)
        }
    }
    
    @IBAction func didTapSettingsButtonUpInside(sender: AnyObject) {
        /* Instantiate the settings view controller for showing the settings view */
        let controller = storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        
        /* Set us as the controllers delegate */
        self.presentViewController(controller, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
