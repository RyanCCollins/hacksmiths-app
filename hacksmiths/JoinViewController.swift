//
//  JoinViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/17/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

/* Various actions on join view */
class JoinViewController: UIViewController {
    
    @IBAction func didTapSigninUpInside(sender: AnyObject) {
        performSegueWithIdentifier("ShowLogin", sender: self)
    }

    @IBAction func didTapVisitSiteUpInside(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(GlobalConstants.hacksmithsURL!)
    }
    
    @IBAction func didTapSignupButtonUpInside(sender: AnyObject) {
        performSegueWithIdentifier("ShowRegistration", sender: self)
    }
    
    @IBAction func didTapSlackLinkButtonUpInside(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(GlobalConstants.slackURL!)
    }
    
    @IBAction func didTapHacksmithsButtonUpInside(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(GlobalConstants.profileURL!)
    }

}
