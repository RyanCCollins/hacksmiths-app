//
//  HacksmithsEventAPIConvenience.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/26/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// More convenience methods, specifically for fetching events.
extension HacksmithsAPIClient {
    
    func fetchEventsFromAPI(completionHandler: CompletionHandler) {
        Alamofire.request(.GET, "https://hacksmiths.io/api/app/event-status", parameters: nil, encoding: .URL, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
            guard response.result.isSuccess else {
                completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "Unable to check event status from network.  Please try again."))
                return
            }
            guard let value = response.result.value as? JsonDict else {
                completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
                return
            }
            
        })
    }
    
    // Fetch events, organization and attendees from the API
    func checkAPIForEvents(completionHandler: CompletionHandler) {
        let method = Routes.EventStatus
        
        
        taskForGETMethod(method, parameters: nil, completionHandler: {success, result, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                if result != nil {
                     
                    if let success = result[HacksmithsAPIClient.JSONResponseKeys.Success] as? Bool,
                           eventDict = result[HacksmithsAPIClient.JSONResponseKeys.Event.event] as? JsonDict {
                        
                        if success != true {
                            
                            completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "An unknown error occured while downloading data from the network.  Please try again."))
                            
                        } else {
                            
                            let event = Event(dictionary: self.dictionaryForEvent(eventDict), context: self.sharedContext)
                            let organization = Organization(dictionary: self.dictionaryForOrganization(eventDict), context: self.sharedContext)
                            organization.fetchImage({success, error in
                                if error != nil {
                                    
                                    completionHandler(success: false, error: error)
                                    
                                } else {
                                   
                                    /*  Save our new event and our organization */
                                    self.sharedContext.performBlockAndWait( {
                                        CoreDataStackManager.sharedInstance().saveContext()
                                    })
                                    
                                    // Set the organization for the event and then carry on
                                    event.organization = organization
                                    self.sharedContext.performBlock({
                                        CoreDataStackManager.sharedInstance().saveContext()
                                    })
                                    
                                    self.fetchAttendees(forEvent: event, completionHandler: {success, error in
                                        if error != nil {
                                            completionHandler(success: false, error: error)
                                        } else {
                                            
                                            self.sharedContext.performBlockAndWait({
                                                CoreDataStackManager.sharedInstance().saveContext()
                                            })
                                            
                                            completionHandler(success: true, error: nil)
                                        }
                                    })
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    func fetchAttendees(forEvent event: Event, completionHandler: CompletionHandler) {
        let eventId = event.eventID
        let method = Routes.EventAttendees + eventId
        
        taskForGETMethod(method, parameters: nil, completionHandler: {success, results, error in
            
            if error != nil {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                if results != nil {
                    if let eventDict = results[HacksmithsAPIClient.JSONResponseKeys.Event.event] as? JsonDict {
                        
                        let success = eventDict["success"] as! Bool ?? false
                        
                        // Another safety check because the app would sometimes return a 200 without proper data.
                        // Need to debug serverside, but this is a needed safety measure at this point.
                        guard success == true else {
                            completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "The server returned an unknown error.  Please try again."))
                            return
                        }
                        
                        let eventId = eventDict[HacksmithsAPIClient.JSONResponseKeys.Event._id] as! String
                        let attendeesArray = results[HacksmithsAPIClient.JSONResponseKeys.Event.attendees] as! [JsonDict]
                        
                        
                        // Batch delete the RSVPs before creating new ones.
                        self.batchDeleteAllRSVPS({success, error in
                            
                            if error != nil {
                                completionHandler(success: false, error: error)
                            }
                        })
                        
                        attendeesArray.map({attendeeDict in
                            
                            let personId = attendeeDict["id"] as! String
                            
                            let newRSVP: JsonDict = [
                                "eventId": eventId,
                                "personId": personId,
                            ]
                            let eventRSVP = EventRSVP(dictionary: newRSVP, context: self.sharedContext)
                        })
                        
                        // Save the context after creating the eventRSVPS.
                        self.sharedContext.performBlockAndWait({
                            CoreDataStackManager.sharedInstance().saveContext()
                        })
                        
                        completionHandler(success: true, error: nil)
                    }
                }
            }
        })
    }
    
    /* Takes an event dictionary and returns a dictionary for creating an event */
    func dictionaryForEvent (event: [String : AnyObject]) -> [String : AnyObject]{
        
        // Initialize our properties to avoid nulls from causing messy Core Data problems
        var id = "", active = false, title = "", description = "", starts = "", ends = "", spotsRemaining: NSNumber = 0
        
        // Awful optionals, but this is the best way to protect against a null value from the API.
        // Will get rid of this in version 2 when we add Realm.
        if let eventId = event[HacksmithsAPIClient.JSONResponseKeys.Event.id] as? String {
            id = eventId
        }
        
        if let activeStatus = event[HacksmithsAPIClient.JSONResponseKeys.Event.active] as? Bool {
            active = activeStatus
        }
        
        if let eventTitle = event[HacksmithsAPIClient.JSONResponseKeys.Event.title] as? String {
            title = eventTitle
        }
        
        if let startDate = event[HacksmithsAPIClient.JSONResponseKeys.Event.starts] as? String {
            starts = startDate
        }
        
        if let endDate = event[HacksmithsAPIClient.JSONResponseKeys.Event.ends] as? String {
            ends = endDate
        }
        
        if let eventDescription = event[HacksmithsAPIClient.JSONResponseKeys.Event.description] as? String {
            description = eventDescription
        }
        
        if let spots = event[HacksmithsAPIClient.JSONResponseKeys.Event.spotsRemaining] as? NSNumber {
            spotsRemaining = spots
        }
        
         let dictionary: JsonDict = [
            "id" : id,
            "active" : active,
            "title" : title,
            "description" : description,
            "starts" : starts,
            "ends" : ends,
            "spotsRemaining": spotsRemaining,
            "featureImage" : event[HacksmithsAPIClient.JSONResponseKeys.Event.featureImage]!
        ]
        return dictionary
    }
    
    func dictionaryForOrganization(eventJsonDict: JsonDict) -> JsonDict {
        
        // Initialize the main properties for the return dictionary
        var orgId = "", orgName = "", orgLogoUrl = "", orgIsHiring = false, orgAbout = "", orgWebsite = ""
        
        // Parse JSON for our organization, protecting against bad data returned from the API.
        if let organization = eventJsonDict[HacksmithsAPIClient.JSONResponseKeys.Organization.dictKey] as? JsonDict {
            if let logoDict = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.logo] as? JsonDict,
                aboutDict = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.description] as? JsonDict {
                
                if let id = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.id] as? String,
                    name = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.name] as? String,
                    about = aboutDict[HacksmithsAPIClient.JSONResponseKeys.Organization.md] as? String,
                    logoUrl = logoDict[HacksmithsAPIClient.JSONResponseKeys.Organization.url] as? String,
                    website = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.website] as? String,
                    isHiring = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.isHiring] as? Bool {
                    
                    // Set our properties
                    orgId = id
                    orgName = name
                    orgLogoUrl = logoUrl
                    orgIsHiring = isHiring
                    orgAbout = about
                    orgWebsite = website
                }
            }
        }
        
        let returnDict: JsonDict = [
            "id" : orgId, "name": orgName,
            "logoUrl": orgLogoUrl, "isHiring" : orgIsHiring,
            "about" : orgAbout, "website" : orgWebsite
        ]
        
        return returnDict
    }
}
