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
    private let personPresenter = PersonPresenter()
    
    @IBOutlet weak var avatarView: RCCircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var debugLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personPresenter.attachView(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let person = person {
            personPresenter.setPerson(person)
        } else {
            personPresenter.setDebugMessage("An error occured while loading the data for this member.")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        personPresenter.detachView(self)
    }
    
    
}

/* MARK: Presenter protocol */
extension PersonViewController: PersonView {
    func configureView(forPerson person: Person) {
        
        if person.image != nil {
            avatarView.userImage = person.image
            avatarView.hidden = false
        }
        
        if person.fullName != nil {
            nameLabel.text = person.fullName
            nameLabel.hidden = false
        }
        
        if let bio = person.bio {
            descriptionLabel.text = bio
            descriptionLabel.hidden = false
        }
        if let twitterUsername = person.twitterUsername {
            twitterLabel.text = twitterUsername
            twitterLabel.hidden = false
        }
        if let githubUsername = person.githubUsername {
            githubLabel.text = githubUsername
            githubLabel.hidden = false
        }
        if let website = person.website {
            websiteLabel.text = website
            websiteLabel.hidden = false
        }
        
    }
    
    func configureDebugView(withMessage message: String) {
        self.debugLabel.text = message
        self.debugLabel.hidden = false
    }
    
}
