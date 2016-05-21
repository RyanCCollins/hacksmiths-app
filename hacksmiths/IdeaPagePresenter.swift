//
//  IdeaPagePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

protocol IdeaPageView {
    func submitAnIdea()
}

class IdeaPagePresenter {
    private var ideaPageView: IdeaPageView?
    
    func attachView(view: IdeaPageView) {
        ideaPageView = view
    }
    
    func detachView(view: IdeaPageView) {
        ideaPageView = nil
    }
}
