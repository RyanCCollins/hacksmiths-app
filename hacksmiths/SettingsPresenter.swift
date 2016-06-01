//
//  SettingsPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/26/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol SettingsView: NSObjectProtocol {
    /** Empty protocol in case complexity grows
     */
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
}