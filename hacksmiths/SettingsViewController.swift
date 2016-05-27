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

protocol SettingsPickerDelegate {
    func didUpdateSettings(userData: UserData)
}

class SettingsViewController: UIViewController {
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    @IBOutlet weak var availableForEvents: UISwitch!
    var delegate: SettingsPickerDelegate?
    @IBOutlet weak var availableAsMentorToggle: UISwitch!
    @IBOutlet weak var lookingForMentorToggle: UISwitch!
    
    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publicProfileToggle: UISwitch!
    var dataChanged: Bool = false
    private let settingPresenter = SettingsPresenter(profileService: UserProfileService())
    var currentUserData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIForUserData()
        settingPresenter.attachView(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        settingPresenter.detachView(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        modalView.animate()
        presentingViewController!.view.transformOut(self)
    }

    @IBAction func performLogoutSegue(sender: AnyObject) {
        UserService.sharedInstance().performLogout()
        performSegueWithIdentifier("LogoutSegue", sender: self)
    }
    
    func setUIForUserData(){
        if let userData = currentUserData {
            pushNotificationsSwitch.on = userData.mobileNotifications
            lookingForMentorToggle.on = userData.needsAMentor
            availableForEvents.on = userData.isAvailableForEvents
            availableAsMentorToggle.on = userData.isAvailableAsAMentor
            publicProfileToggle.on = userData.isPublic
            pushNotificationsSwitch.on = userData.mobileNotifications
        }
    }
    
    @IBAction func didTapToggle(sender: UISwitch) {
        guard currentUserData != nil else {
            return
        }
        let toggle = Toggle(rawValue: sender.tag)
        let newValue = sender.on
        dataChanged = true
        switch toggle! {
        case .PushNotifications:
            currentUserData?.mobileNotifications = newValue
        case .AvailableForEvents:
            currentUserData?.isAvailableForEvents = newValue
        case .PublicProfile:
            currentUserData?.isPublic = newValue
        case .AvailableAsAMentor:
            currentUserData?.isAvailableAsAMentor = newValue
        case .LookingForAMentor:
            currentUserData?.needsAMentor = newValue
        }
    }
    
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        presentingViewController!.view.transformIn(self)
        if dataChanged {
            delegate?.didUpdateSettings(currentUserData!)
        }
        modalView.animation = "slideRight"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    
}

extension SettingsViewController: SettingsView {
    func didChangeSettings(value: Bool) {
        
    }
}

enum Toggle: Int {
    case PushNotifications = 1, AvailableForEvents,
    PublicProfile, AvailableAsAMentor, LookingForAMentor
}


