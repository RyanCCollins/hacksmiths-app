//
//  ProfilePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol ProfileView {
    func didUpdateUserData(didSucceed: Bool, error: NSError?)
    func didGetUserDataFromAPI(userData: UserData?, error: NSError?)
}

class ProfilePresenter {
    private var profileView: ProfileView?
    var userProfileService: UserProfileService
    
    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
    }
    
    func attachView(profileView: ProfileView) {
        self.profileView = profileView
    }
    
    func detachView(profileView: ProfileView) {
        self.profileView = nil
    }
    
    func submitDataToAPI(userData: UserData) {
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didUpdateUserData(false, error: GlobalErrors.BadCredentials)
            return
        }

        let userJSON = UserJSONObject(userData: userData)
        userProfileService.updateProfile(userJSON, userID: UserService.sharedInstance().userId!).then() {
            Void in
            self.profileView?.didUpdateUserData(true, error: nil)
            }.error {
                error in
                self.profileView?.didUpdateUserData(false, error: error as NSError)
        }
    }
    
    func fetchUserData() {
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didGetUserDataFromAPI(nil, error: GlobalErrors.BadCredentials)
            return
        }
        
        userProfileService.getProfile(UserService.sharedInstance().userId!).then(){
            userData -> () in
            self.profileView?.didGetUserDataFromAPI(userData, error: nil)
        }.error {
            error in
            self.profileView?.didGetUserDataFromAPI(nil, error: error as NSError)
        }
    }
}
