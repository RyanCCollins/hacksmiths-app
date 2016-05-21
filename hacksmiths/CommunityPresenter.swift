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
    func fetchCommunity(sender: CommunityPresenter, didFailWithError error: NSError?, didSucceedWithMembers members: [Person]?)
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
        
    }
}
