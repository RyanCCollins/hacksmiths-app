//
//  ProfilePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol ProfileView: NSObjectProtocol {
    func showLoading()
    func hideLoading()
    func setActivityIndicator(withMessage message: String?)
    func didUpdateUserData(didSucceed: Bool, error: NSError?)
    func didGetUserDataFromAPI(userData: UserData?, error: NSError?)
    func didLoadCachedUserData(userData: UserData?, error: NSError?)
}

class ProfilePresenter {
    private var profileView: ProfileView?
    private var userProfileService: UserProfileService
    
    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
    }
    
    func attachView(profileView: ProfileView) {
        self.profileView = profileView
        profileView.setActivityIndicator(withMessage: "Synching")
    }
    
    func detachView(profileView: ProfileView) {
        self.profileView = nil
    }
    
    func submitDataToAPI(userData: UserData) {
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didUpdateUserData(false, error: GlobalErrors.BadCredentials)
            return
        }

        profileView?.showLoading()
        let userJSON = UserJSONObject(userData: userData)
        userProfileService.updateProfile(userJSON, userID: UserService.sharedInstance().userId!).then() {
            Void in
            self.profileView?.didUpdateUserData(true, error: nil)
            }.error {
                error in
                self.profileView?.didUpdateUserData(false, error: error as NSError)
        }
    }
    
    func fetchCachedData() {
        /* Ensure that user is authenticated before loading cached data*/
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didLoadCachedUserData(nil, error: nil)
            return
        }
        
        userProfileService.fetchSavedUserData().then() {
            userData -> () in
            if userData != nil {
                self.profileView?.didLoadCachedUserData(userData, error: nil)
            } else {
                self.profileView?.didLoadCachedUserData(nil, error: nil)
            }
            }.error {error in
                self.profileView?.didLoadCachedUserData(nil, error: error as NSError)
            }
    }
    
    func fetchUserDataFromAPI() {
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didGetUserDataFromAPI(nil, error: GlobalErrors.BadCredentials)
            return
        }
        profileView?.showLoading()
        userProfileService.getProfile(UserService.sharedInstance().userId!).then(){
            userData -> () in
            userData?.fetchImages().then() {
                    self.profileView?.didGetUserDataFromAPI(userData, error: nil)
                }.error{error in
                    self.profileView?.didGetUserDataFromAPI(nil, error: error as NSError)
                }
        }.error {
            error in
            self.profileView?.didGetUserDataFromAPI(nil, error: error as NSError)
        }
    }
}
