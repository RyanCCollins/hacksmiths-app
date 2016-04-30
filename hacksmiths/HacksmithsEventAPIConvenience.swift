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
                guard let value = response.result.value as? NSData else {
                    completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
                    return
                }
            
                let jsonData = JSON(data: value)
                let dictionaryForEvent = self.dictionaryForEvent(jsonData)
                let event = Event(dictionary: dictionaryForEvent, context: self.sharedContext)
                self.sharedContext.performBlockAndWait({
                    CoreDataStackManager.sharedInstance().saveContext()
                })
                
                let organizationDict = self.dictionaryForOrganization(jsonData)
                let organization = Organization(dictionary: organizationDict, context: self.sharedContext)
                
                event.organization = organization
                
                self.sharedContext.performBlockAndWait({
                    CoreDataStackManager.sharedInstance().saveContext()
                })
                
                completionHandler(success: true, error: nil)
        })
    }
    
    func fetchEventAttendees(eventID: String, completionHandler: CompletionHandler) {
        Alamofire.request(.GET, "https://hacksmiths.io/api/event/\(eventID)", parameters: nil, encoding: .URL, headers: nil)
            .validate().responseJSON(completionHandler: {response in
                
                guard response.result.isSuccess else {
                    completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
                    return
                }
                
                guard let value = response.result.value else {
                    completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
                    return
                }
                
                let jsonData = JSON(value)
                
                let eventId = jsonData[HacksmithsAPIClient.JSONResponseKeys.Event._id].string
                let attendeesArray = jsonData[HacksmithsAPIClient.JSONResponseKeys.Event.attendees].arrayObject as? [JsonDict]
                
                
                // Batch delete the RSVPs before creating new ones.
                self.batchDeleteAllRSVPS({success, error in
                    
                    if error != nil {
                        completionHandler(success: false, error: error)
                    }
                })
                
                // Loop through and create an RSVP record for each attendee.
                for attendee in attendeesArray! {
                    let personId = attendee["id"] as! String
                    let eventRSVP = EventRSVP(personId: personId, eventId: eventId!, context: self.sharedContext)
                    
                }

                // Save the context after creating the eventRSVPS.
                self.sharedContext.performBlockAndWait({
                    CoreDataStackManager.sharedInstance().saveContext()
                })
                
                completionHandler(success: true, error: nil)
                
        })
    }
    
    
//    // Fetch events, organization and attendees from the API
//    func checkAPIForEvents(completionHandler: CompletionHandler) {
//        let method = Routes.EventStatus
//        
//        
//        taskForGETMethod(method, parameters: nil, completionHandler: {success, result, error in
//            if error != nil {
//                completionHandler(success: false, error: error)
//            } else {
//                if result != nil {
//                     
//                    if let success = result[HacksmithsAPIClient.JSONResponseKeys.Success] as? Bool,
//                           eventDict = result[HacksmithsAPIClient.JSONResponseKeys.Event.event] as? JsonDict {
//                        
//                        if success != true {
//                            
//                            completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "An unknown error occured while downloading data from the network.  Please try again."))
//                            
//                        } else {
//                            
//                            let event = Event(dictionary: self.dictionaryForEvent(eventDict), context: self.sharedContext)
//                            let organization = Organization(dictionary: self.dictionaryForOrganization(eventDict), context: self.sharedContext)
//                            organization.fetchImage({success, error in
//                                if error != nil {
//                                    
//                                    completionHandler(success: false, error: error)
//                                    
//                                } else {
//                                   
//                                    /*  Save our new event and our organization */
//                                    self.sharedContext.performBlockAndWait( {
//                                        CoreDataStackManager.sharedInstance().saveContext()
//                                    })
//                                    
//                                    // Set the organization for the event and then carry on
//                                    event.organization = organization
//                                    self.sharedContext.performBlock({
//                                        CoreDataStackManager.sharedInstance().saveContext()
//                                    })
//                                    
//                                    self.fetchAttendees(forEvent: event, completionHandler: {success, error in
//                                        if error != nil {
//                                            completionHandler(success: false, error: error)
//                                        } else {
//                                            
//                                            self.sharedContext.performBlockAndWait({
//                                                CoreDataStackManager.sharedInstance().saveContext()
//                                            })
//                                            
//                                            completionHandler(success: true, error: nil)
//                                        }
//                                    })
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        })
//    }
//    
//    func fetchAttendees(forEvent event: Event, completionHandler: CompletionHandler) {
//        let eventId = event.eventID
//        let method = Routes.EventAttendees + eventId
//        
//        taskForGETMethod(method, parameters: nil, completionHandler: {success, results, error in
//            
//            if error != nil {
//                
//                completionHandler(success: false, error: error)
//                
//            } else {
//                
//                if results != nil {
//                    if let eventDict = results[HacksmithsAPIClient.JSONResponseKeys.Event.event] as? JsonDict {
//                        
//                        let success = eventDict["success"] as! Bool ?? false
//                        
//                        // Another safety check because the app would sometimes return a 200 without proper data.
//                        // Need to debug serverside, but this is a needed safety measure at this point.
//                        guard success == true else {
//                            completionHandler(success: false, error: Errors.constructError(domain: "HacksmithsAPIClient", userMessage: "The server returned an unknown error.  Please try again."))
//                            return
//                        }
//                        
//                        let eventId = eventDict[HacksmithsAPIClient.JSONResponseKeys.Event._id] as! String
//                        let attendeesArray = results[HacksmithsAPIClient.JSONResponseKeys.Event.attendees] as! [JsonDict]
//                        
//                        
//                        // Batch delete the RSVPs before creating new ones.
//                        self.batchDeleteAllRSVPS({success, error in
//                            
//                            if error != nil {
//                                completionHandler(success: false, error: error)
//                            }
//                        })
//                        
//                        attendeesArray.map({attendeeDict in
//                            
//                            let personId = attendeeDict["id"] as! String
//                            
//                            let newRSVP: JsonDict = [
//                                "eventId": eventId,
//                                "personId": personId,
//                            ]
//                            let eventRSVP = EventRSVP(dictionary: newRSVP, context: self.sharedContext)
//                        })
//                        
//                        // Save the context after creating the eventRSVPS.
//                        self.sharedContext.performBlockAndWait({
//                            CoreDataStackManager.sharedInstance().saveContext()
//                        })
//                        
//                        completionHandler(success: true, error: nil)
//                    }
//                }
//            }
//        })
//    }
    
    /* Takes an event dictionary and returns a dictionary for creating an event */
    func dictionaryForEvent (eventJSON: JSON) -> JsonDict{
        
        let id = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.id].string
        let active = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.active].boolValue
        let marketingInfo = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.marketingInfo].string ?? ""
        let title = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.title].string
        let description = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.description].string ?? ""
        let spotsRemaining = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.spotsRemaining].int ?? 0
        
        let registrationStartDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.registrationStartDate].string ?? ""
        let registrationEndDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.registrationEndDate].string ?? ""
        let startDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.starts].string ?? ""
        let endDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.ends].string ?? ""
        
        // Set up our dictionary
        var dictionary: JsonDict = [
            "id" : id!,
            "active" : active,
            "marketingInfo": marketingInfo,
            "title" : title!,
            "description" : description,
            "spotsRemaining": spotsRemaining,
        ]
        
        if let eventStartDate = dateFromString(registrationStartDateString) {
            dictionary["registrationStartDate"] = eventStartDate
        }
        
        if let eventEndDate = dateFromString(registrationEndDateString) {
            dictionary["registrationEndDate"] = eventEndDate
        }
        
        if let eventStartDate = dateFromString(startDateString), eventEndDate = dateFromString(endDateString) {
            dictionary["starts"] = eventStartDate
            dictionary["ends"] = eventEndDate
        }
        
        if let featureImage = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.featureImage].dictionary {
            if let imageURL = featureImage["url"]!.string {
                dictionary["featureImage"] = imageURL
            }
        }
        
        return dictionary
    }
    
    func dictionaryForOrganization(eventJsonDict: JSON) -> JsonDict {
        
        var returnDict: JsonDict = [
            "id": "",
            "name": "",
            "logoUrl": "",
            "isHiring": false,
            "website": "",
            "about": ""
        ]
        
        if let organization = eventJsonDict[HacksmithsAPIClient.JSONResponseKeys.Organization.dictKey].dictionary {
            
            let orgId = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.id]!.string
            let orgName = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.name]!.string
            let isHiring = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.isHiring]!.bool
            
            returnDict["id"] = orgId
            returnDict["name"] = orgName
            returnDict["isHiring"] = isHiring
            
            if let logoURL = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.logo]![HacksmithsAPIClient.JSONResponseKeys.Organization.url].string {
                returnDict["logoUrl"] = logoURL
            }
            
            if let about = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.description]![HacksmithsAPIClient.JSONResponseKeys.Organization.md].string {
                returnDict["about"] = about
            }
            
            if let website = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.website]!.string {
                returnDict["website"] = website
            }
            
        }
        
        return returnDict
    }
    
    func dateFromString(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ssZZZZZ"
        let date = dateFormatter.dateFromString(dateString)
        
        return date
    }
}