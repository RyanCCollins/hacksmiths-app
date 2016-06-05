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
    @IBOutlet weak var starButton: UIButton!

    var websiteUrl: NSURL?
    var twitterUrl: NSURL?
    var githubUrl: NSURL?
    
    /** MARK: Life cycle methods
     */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        personPresenter.attachView(self)
        if let person = person {
            personPresenter.setPerson(person)
        } else {
            personPresenter.setDebugMessage("An error occured while loading the data for this member.")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        personPresenter.detachView(self)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }

    /** Method called when one of the person buttons is tapped.
     *
     *  @param sender - the sender of the event
     *  @return None
     */
    @IBAction func didTapButtonUpInside(sender: AnyObject) {
        let button = PersonButton(rawValue: sender.tag)
        switch button! {
        case .TwitterButton:
            if let url = twitterUrl {
                handleOpenURL(url)
            }
        case .GithubButton:
            if let url = githubUrl {
                handleOpenURL(url)
            }
        case .WebsiteButton:
            if let url = websiteUrl {
                handleOpenURL(url)
            }
        }
    }
    
    /** Handle opening a URL by the app delegate when a button is tapped.
     */
    func handleOpenURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}

/* MARK: Presenter protocol */
extension PersonViewController: PersonView {
    /** Configure view for the current person
     *
     *  @param person - the Person for whom the view is being configured.
     *  @return None
     */
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
            if website.length > 0 {
                websiteStackView.hidden = false
                websiteButton.setTitle(website, forState: .Normal)
                let websiteURL = NSURL(string: website)
                if websiteURL != nil {
                    self.websiteUrl = websiteURL
                }
            }
        }
    }
    
    func configureDebugView(withMessage message: String) {
        self.debugLabel.text = message
        self.debugLabel.hidden = false
    }
    
    private enum PersonButton: Int {
        case TwitterButton = 1,
             GithubButton,
             WebsiteButton
    }
}
