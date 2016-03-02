//
//  PersonViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/9/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {
    let person: Person? = nil
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personDescriptionLabel: UITextView!
    @IBOutlet weak var personTwitterLabel: UILabel!
    @IBOutlet weak var personGithubLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personTwitterLabel.hidden = true
        personGithubLabel.hidden = true
        
        configurePersonView()
    }
    
    func configurePersonView() {
        if let person = person {
            personImageView.image = person.image
            personNameLabel.text = person.firstName + " " + person.lastName
            personDescriptionLabel.text = person.description
            
            if let twitterUsername = person.twitterUsername {
                personTwitterLabel.text = twitterUsername
                personTwitterLabel.hidden = false
            }
            
            if let githubUserName = person.githubUsername {
                personGithubLabel.text = githubUserName
                personGithubLabel.hidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
