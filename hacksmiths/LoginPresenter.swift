//
//  LoginPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol LoginView {
    func startLoading()
    func finishLoading()
    func didLogin(didSucceed: Bool, didFail error: NSError?)
    func subscribeToKeyboardNotifications()
    func unsubscribeToKeyboardNotifications()
}


class LoginPresenter: NSObject {
    private var loginView: LoginView?
    
    func attachView(view: LoginView){
        self.loginView = view
        loginView?.subscribeToKeyboardNotifications()
    }
    
    func detachView() {
        self.loginView = nil
        loginView?.unsubscribeToKeyboardNotifications()
    }
    
    func authenticateUser(username: String, password: String) {
        loginView?.startLoading()
        HacksmithsAPIClient.sharedInstance().authenticateWithCredentials(username, password: password, completionHandler: {success, error in
            if error != nil {
                self.loginView?.didLogin(false, didFail: error)
            } else {
                self.loginView?.didLogin(true, didFail: nil)
            }
        })
    }
}
