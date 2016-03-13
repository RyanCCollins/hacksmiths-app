//
//  JoinViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapSigninUpInside(sender: AnyObject) {
        performSegueWithIdentifier("ShowLogin", sender: self)
    }

    @IBAction func didTapVisitSiteUpInside(sender: AnyObject) {
        let url = NSURL(string: "hacksmiths.io")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func didTapSignupButtonUpInside(sender: AnyObject) {
        performSegueWithIdentifier("ShowRegistration", sender: self)
    }
}
