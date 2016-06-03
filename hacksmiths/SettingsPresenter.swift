//
//  SettingsPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/26/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol SettingsView: NSObjectProtocol {
    func didSetUserData(userData: UserData?, error: NSError?)
}

/** Settings presenter class, not yet being utilized
 *  But is here in case of growing complexity since
 *  The rest of the app implements MVP
 */
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
    
    func setUserData(userData: UserData?) {
        if userData != nil {
            settingsView?.didSetUserData(userData, error: nil)
        } else {
            settingsView?.didSetUserData(nil, error: GlobalErrors.GenericError)
        }
    }
}