//
//  ProfilePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol ProfileView {
    func didSubmitDataForUpdate(userData: UserData, userJSON: UserJSONObject)
    func didGetUserDataFromAPI(withData: UserData, error: NSError?)
}

class ProfilePresenter {
    private var profileView: ProfileView?
    
    func attachView(profileView: ProfileView) {
        self.profileView = profileView
    }
    
    func detachView(profileView: ProfileView) {
        self.profileView = nil
    }
    
    func submitDataToAPI() {
        
        HacksmithsAPIClient.sharedInstance().updateProfile(<#T##body: JsonDict##JsonDict#>, completionHandler: <#T##CompletionHandler##CompletionHandler##(success: Bool, error: NSError?) -> Void#>)
    }
}
