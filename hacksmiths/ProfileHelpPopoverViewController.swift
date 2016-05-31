//
//  ProfileHelpPopoverViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/30/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class ProfileHelpPopoverViewController: UIViewController {
    @IBOutlet weak var helpTextLabel: UILabel!
    var helpText = ""
    
    override func viewDidLoad() {
        helpTextLabel.text = helpText
        self.preferredContentSize = CGSizeMake(200, 200) 
    }
}
