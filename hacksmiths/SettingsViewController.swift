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

protocol SettingsDelegate {
    func didSetUserData(user: UserData)
}

class SettingsViewController: UIViewController {
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var availableForEvents: UISwitch!

    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publicProfileToggle: UISwitch!
    
    var userData: UserData? = nil
    var codeText: String = ""
    var data: SpringView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
    }
    
    
    func setupView() {
        
    }
    
    
    @IBAction func didTapPushNotificationsToggle(sender: UISwitch) {
        
    }
    
    @IBAction func didTapAvailableForEvents(sender: UISwitch) {
        
    }
    
    @IBAction func didTapPublicProfile(sender: UISwitch) {
        
    }
    
    
    func setUIForUserData(userData: UserData){
        
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
