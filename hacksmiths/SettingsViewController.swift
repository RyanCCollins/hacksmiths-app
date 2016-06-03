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

/** Protocol for when settings are updated, letting the delegate handle submission to API.
 */
protocol SettingsPickerDelegate {
    func didUpdateSettings(userData: UserData)
}

/** Settings View Controller - Handles setting User Settings.
 */
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
    
    /** MARK: Lifecycle methods
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        settingPresenter.attachView(self)
        settingPresenter.setUserData(currentUserData)
    }
    
    override func viewWillDisappear(animated: Bool) {
        settingPresenter.detachView(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        modalView.animate()
        presentingViewController!.view.transformOut(self)
    }
    
    /** Perform logout segue when button is tapped.  If an error occurs, alert the user
     */
    @IBAction func performLogoutSegue(sender: AnyObject) {
        UserService.sharedInstance().performLogout().then() {
            self.performSegueWithIdentifier("LogoutSegue", sender: self)
        }.error{error in
            self.alertController(withTitles: ["Ok", "Retry"], message: "Unable to log you out for some unknown reason.  Please try again", callbackHandler: [nil, {Void in
                self.performLogoutSegue(self)
            }])
        }
    }
    
    /** Translate user data into UI for settings
     * @params - userData: UserData - the user's data to map to the UI.
     * @return - NONE
     */
    func setupUserInterface(withUserData userData: UserData){
        pushNotificationsSwitch.on = userData.mobileNotifications
        lookingForMentorToggle.on = userData.needsAMentor
        availableForEvents.on = userData.isAvailableForEvents
        availableAsMentorToggle.on = userData.isAvailableAsAMentor
        publicProfileToggle.on = userData.isPublic
        pushNotificationsSwitch.on = userData.mobileNotifications
    }
    
    /** When toggle is tapped, translate to the value stored in user data.
     *  @params - Sender: UISwitch - the sending toggle, which corresponds to the Enum Toggle value.
     */
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
    
    /** Perform segue back to presenting view, sending current data
     *  If it has changed.
     *  @params - Sender: AnyObject - The IBAction from storyboard
     */
    @IBAction func closeButtonPressed(sender: AnyObject) {
        presentingViewController!.view.transformIn(self)
        if dataChanged {
            delegate?.didUpdateSettings(currentUserData!)
            dataChanged = false
        }
        modalView.animation = "slideRight"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
}

/** Set the user data to match the user interface and handle any errors.
 *  Utilizing the model view presenter pattern.
 */
extension SettingsViewController: SettingsView {
    func didSetUserData(userData: UserData?, error: NSError?) {
        if userData != nil {
            setupUserInterface(withUserData: userData!)
        } else {
            alertController(withTitles: ["Ok"], message: "An error occured while loading your data.  Please try again.", callbackHandler: [nil])
        }
    }
}

/** Toggle enumeration for the settings toggle types.
 *  Maps to the tag of the item in storyboard
 */
enum Toggle: Int {
    case PushNotifications = 1, AvailableForEvents,
    PublicProfile, AvailableAsAMentor, LookingForAMentor
}


