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
    @IBOutlet weak var codeTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    var codeText: String = ""
    var data: SpringView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        modalView.animate()
        
        UIApplication.sharedApplication().sendAction("minimizeView:", to: nil, from: self, forEvent: nil)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().sendAction("maximizeView:", to: nil, from: self, forEvent: nil)
        
        modalView.animation = "slideRight"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    


}
