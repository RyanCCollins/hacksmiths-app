//
//  EditProfilePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//


/* Protocol for delegating submission of profile back to the sending view */
protocol EditProfileDelegate {
    func didSubmitEditedData(userData: UserData)
}

/* Following the Model View Presenter Pattern in case complexity grows */
protocol EditProfileView: NSObjectProtocol {
    func showLoading()
    func hideLoading()
}

class EditProfilePresenter {
    private var editProfileView: EditProfileView?
    
    func attachView(view: EditProfileView) {
        self.editProfileView = view
    }
    
    func detachView(view: EditProfileView) {
        self.editProfileView = nil
    }
}