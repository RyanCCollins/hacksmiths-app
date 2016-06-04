//
//  CommunityPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
/** Community View Protocol for following MVP pattern
 */
protocol CommunityView {
    func startLoading()
    func finishLoading()
    func fetchCommunity(sender: CommunityPresenter, didSucceed: Bool, didFailWithError error: NSError?)
}

/** Community presenter for following MVP pattern
 *  Communicates with the model and view, taking the logic out of the view.
 */
class CommunityPresenter {
    private var communityView: CommunityView?
    private var personService: PersonService?
    
    init(){}
    
    func attachView(view: CommunityView, personService: PersonService) {
        communityView = view
        self.personService = personService
    }
    
    func detachView(view: CommunityView) {
        communityView = nil
        self.personService = nil
    }
    
    /** Get the member list from the API and store to core data
     *  Will send messages through the presenter to update the view.
     *
     *  @param None
     *  @return None
     */
    func fetchCommunityMembers() {
        /* Safely unwrap the person service */
        guard let personService = personService where self.personService != nil else {
            return
        }
        /* Get the member list from the person service*/
        personService.getMemberList().then() {
            Void in
                self.communityView?.fetchCommunity(self, didSucceed: true, didFailWithError: nil)
            }.error{error in
                self.communityView?.fetchCommunity(self, didSucceed: false, didFailWithError: error as NSError)
            }
    }
}
