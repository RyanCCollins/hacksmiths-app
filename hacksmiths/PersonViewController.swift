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
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var twitterStackView: UIStackView!
    @IBOutlet weak var githubStackView: UIStackView!
    @IBOutlet weak var websiteStackView: UIStackView!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var githubButton: UIButton!
    
    var websiteUrl: NSURL?
    var twitterUrl: NSURL?
    var githubUrl: NSURL?
    
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
    
    @IBAction func didTapButtonUpInside(sender: AnyObject) {
        switch sender.tag {
        case 1:
            if let url = twitterUrl {
                handleOpenURL(url)
            }
        case 2:
            if let url = githubUrl {
                handleOpenURL(url)
            }
        case 3:
            if let url = websiteUrl {
                handleOpenURL(url)
            }
        default:
            break
        }
    }
    
    func handleOpenURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }

    
}

enum Button {
    case Twitter(url: NSURL?, title:String, hidden: Bool, tag: Int)
    case Github(url: NSURL?, title: String?, hidden: Bool, tag: Int)
    case Website(url: NSURL?, title: String?, hidden: Bool, tag: Int)
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
            twitterUrl = person.twitterURL
            let title = "@\(twitterUsername)"
            twitterButton.setTitle(title, forState: .Normal)
            twitterStackView.hidden = false
        }
        if let githubUsername = person.githubUsername {
            githubUrl = person.githubURL
            githubButton.setTitle(githubUsername, forState: .Normal)
            githubStackView.hidden = false
        }
        
        if let website = person.website {
            websiteStackView.hidden = false
            websiteButton.setTitle(website, forState: .Normal)
            let websiteURL = NSURL(string: website)
            if websiteURL != nil {
                self.websiteUrl = websiteURL
            }
        }
        
    }
    
    func configureDebugView(withMessage message: String) {
        self.debugLabel.text = message
        self.debugLabel.hidden = false
    }
    
}
