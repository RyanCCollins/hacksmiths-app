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
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var availableForEvents: UISwitch!

    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publicProfileToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
    }
    
    
    @IBAction func didTapPushNotificationsToggle(sender: UISwitch) {
        if ProfileDataFetcher.sharedInstance.userData != nil {
            ProfileDataFetcher.sharedInstance.userData?.mobileNotifications = sender.on
        }
    }
    
    @IBAction func didTapAvailableForEvents(sender: UISwitch) {
        if ProfileDataFetcher.sharedInstance.userData != nil {
            ProfileDataFetcher.sharedInstance.userData?.isAvailableForEvents = sender.on
        }
    }
    
    @IBAction func didTapPublicProfile(sender: UISwitch) {
        if ProfileDataFetcher.sharedInstance.userData != nil {
            ProfileDataFetcher.sharedInstance.userData?.isPublic = sender.on
        }
    }
    
    
    func setUIForUserData(){
        if ProfileDataFetcher.sharedInstance.userData != nil {
            
            let notificationsIsOn = ProfileDataFetcher.sharedInstance.userData?.mobileNotifications
            let isAvailableForEvents = ProfileDataFetcher.sharedInstance.userData?.isAvailableForEvents
            let publicProfile = ProfileDataFetcher.sharedInstance.userData?.isPublic
            
            pushNotificationsSwitch.setOn(notificationsIsOn!, animated: false)
            availableForEvents.setOn(isAvailableForEvents!, animated: false)
            publicProfileToggle.setOn(publicProfile!, animated: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIForUserData()
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
