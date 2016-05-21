//
//  LoginPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol LoginView {
    func showLoading()
    func hideLoading()
}


class LoginPresenter: NSObject {
    private var loginView: LoginView?
    
    func attachView(view: LoginView){
        self.loginView = view
    }
    
    func detachView() {
        self.loginView = nil
    }
}
