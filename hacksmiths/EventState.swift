//
//  EventState.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

/* Determination of Event state from API values. API also returns a Bool active key */
enum EventState: String {
    case Draft = "draft"
    case Past = "past"
    case Voting = "votingInProgress"
    case Active = "active"
    case Scheduled = "scheduled"
}