//
//  SettingsPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/26/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol SettingsView: NSObjectProtocol {
    func didChangeSettings(value: Bool)
}

class SettingsPresenter {
    private var settingsView: SettingsView?
    private let profileService: UserProfileService?
    
    init(profileService: UserProfileService) {
        self.profileService = profileService
    }
    
    func attachView(view: SettingsView) {
        self.settingsView = view
    }
    
    func detachView(view: SettingsView) {
        self.settingsView = nil
    }
    
    func updateSettings(value: Bool) {
        guard let userId = UserService.sharedInstance().userId else {
            return
        }
        
    }
    
    func setSettings(userData: UserData) {
        
    }
}

struct Settings {
    let pushNotifications: Bool
    let isAvailableForEvents: Bool
    let publicProfile: Bool
    let availableAsAMentor: Bool
    let lookingForAMentor: Bool
    init(userData: UserData) {
        self.publicProfile = userData.isPublic
        self.isAvailableForEvents = userData.isAvailableForEvents
        self.lookingForAMentor = userData.needsAMentor
        self.availableAsAMentor = userData.isAvailableAsAMentor
        self.pushNotifications = userData.mobileNotifications
    }
}
