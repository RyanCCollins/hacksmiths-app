//
//  CommunityPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol CommunityView {
    func startLoading()
    func finishLoading()
    func fetchCommunity(sender: CommunityPresenter, didSucceed: Bool, didFailWithError error: NSError?)
    func showNoDataLabel()
}

class CommunityPresenter {
    private var communityView: CommunityView?
    
    init(){}
    func attachView(view: CommunityView) {
        communityView = view
    }
    
    func detachView(view: CommunityView) {
        communityView = nil
    }
    
    func fetchCommunityMembers() {
        let body = [String : AnyObject]()
        HacksmithsAPIClient.sharedInstance().getMemberList(body, completionHandler: {result, error in
            
            if error != nil {
                
                self.communityView?.fetchCommunity(self, didSucceed: false, didFailWithError: error)
                
            } else {
                
                self.communityView?.fetchCommunity(self, didSucceed: true, didFailWithError: nil)
            }
        })
    }
}
