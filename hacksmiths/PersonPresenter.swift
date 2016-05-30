//
//  PersonPresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

protocol PersonView {
    func configureView(forPerson person: Person)
    func configureDebugView(withMessage message: String)
    func setStar(starred: Bool)
}

class PersonPresenter: NSObject {
    private var personView: PersonView?
    
    func attachView(view: PersonView){
        personView = view
    }
    
    func detachView(view: PersonView) {
        personView = nil
    }
    
    func setPerson(person: Person) {
        personView?.configureView(forPerson: person)
    }
    
    func setDebugMessage(message: String) {
        personView?.configureDebugView(withMessage: message)
    }
    
    func fetchPersonStar() -> Bool {
        return true
    }
}
