//
//  SettingsViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

// Note: Spring is a great animation library created by a designer turned iOS Dev
// See here: 

import UIKit
import Spring

class SettingsViewController: UIViewController {

    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var userData: UserData? = nil
    var codeText: String = ""
    var data: SpringView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        modalView.animate()
        presentingViewController!.view.transformOut(self)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        presentingViewController!.view.transformIn(self)
        
        modalView.animation = "slideRight"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
}
