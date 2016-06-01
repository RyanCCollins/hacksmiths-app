//
//  EventHelpPopoverViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 6/1/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
/** A bit of a duplication of the Profile Help Popover.  If need be, will make this into a reusable class. 
 */
class EventHelpPopoverViewController: UIViewController {
    @IBOutlet weak var helpTextLabel: UILabel!
    var helpText = ""
    
    override func viewDidLoad() {
        helpTextLabel.text = helpText
        self.preferredContentSize = CGSizeMake(300, 200)
    }
}
