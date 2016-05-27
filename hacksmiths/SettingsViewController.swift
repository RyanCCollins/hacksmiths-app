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
    
    private let settingPresenter = SettingsPresenter(profileService: UserProfileService())
    
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
        
//        if ProfileDataFetcher.sharedInstance.userData != nil {
//            
//            let notificationsIsOn = ProfileDataFetcher.sharedInstance.userData?.mobileNotifications
//            let isAvailableForEvents = ProfileDataFetcher.sharedInstance.userData?.isAvailableForEvents
//            let publicProfile = ProfileDataFetcher.sharedInstance.userData?.isPublic
//            
//            pushNotificationsSwitch.setOn(notificationsIsOn!, animated: false)
//            availableForEvents.setOn(isAvailableForEvents!, animated: false)
//            publicProfileToggle.setOn(publicProfile!, animated: false)
//        }
    }
    
    @IBAction func didTapToggle(sender: UISwitch) {
        let toggle = Toggle(rawValue: sender.tag)
        switch toggle! {
        case .PushNotifications:
            let newValue = sender.on
            break
        default:
            break
//        case .AvailableForEvents:
//        case .PublicProfile:
//        case .AvailableAsAMenter:
//        case .LookingForAMentor:
            
        }
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

extension SettingsViewController: SettingsView {
    func didChangeSettings(value: Bool) {
        print(value)
    }
}

enum Toggle: Int {
    case PushNotifications = 1, AvailableForEvents,
    PublicProfile, AvailableAsAMentor, LookingForAMentor
}

enum ToggleValue {
    case PushNotifications(newValue: Bool)
    case AvailableForEvents(newValue: Bool)
    case PublicProfile(newValue: Bool)
    case AvailableAsAMentor(newValue: Bool)
    case LookingForAMentor(newValue: Bool)
}

