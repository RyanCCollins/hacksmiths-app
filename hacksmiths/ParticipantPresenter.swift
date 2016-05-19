//
//  ParticipantPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/18/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation
import CoreData

protocol ParticipantView {
    func startLoading()
    func endLoading()
    func getParticipants(forEvent event: Event)
}

class ParticipantPresenter {
    private var participantView: ParticipantView?
    
    func attachView(view: ParticipantView){
        participantView = view
    }
    
    func detachView(view: ParticipantView) {
        participantView = nil
    }
}
