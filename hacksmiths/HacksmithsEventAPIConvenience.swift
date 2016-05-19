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
import PromiseKit
import CoreData

// More convenience methods, specifically for fetching events.
extension HacksmithsAPIClient {
    
//    func fetchEventsFromAPI(completionHandler: CompletionHandler) {
//        let manager = Manager()
//        
//        let router = EventRouter()
//        
//        Alamofire.request(.GET, "https://hacksmiths.io/api/app/event-status", parameters: nil, encoding: .URL, headers: nil)
//            .responseJSON(completionHandler: {response in
//                
//                switch response.result {
//                case .Success(let responseData):
//                    var organizationError: NSError?
//                    let json = JSON(responseData)
//                    let eventJSON = json["event"]
//                    let dictionaryForEvent = self.dictionaryForEvent(eventJSON)
//                    
//                    let event = Event(dictionary: dictionaryForEvent!, context: self.sharedContext)
//                    
//                    self.sharedContext.performBlockAndWait({
//                        CoreDataStackManager.sharedInstance().saveContext()
//                    })
//                    
//                    self.parseOrganization(eventJSON, completionHandler: {success, result, error in
//                        
//                        if error != nil {
//                            event.organization = nil
//                            organizationError = error
//                        } else {
//                            let theOrganization = result as? Organization
//                            event.organization = theOrganization
//                        }
//                        
//                    })
//                    
//                    self.sharedContext.performBlockAndWait({
//                        CoreDataStackManager.sharedInstance().saveContext()
//                    })
//                    
//                    event.fetchImages({success, error in
//                        if error != nil {
//                            completionHandler(success: false, error: error)
//                        } else {
//                            completionHandler(success: true, error: nil)
//                        }
//                    })
//                    
//                case .Failure(let error):
//                    completionHandler(success: false, error: error)
//                }
//        })
//    }
//    
//    private func parseOrganization(eventJson: JSON, completionHandler: CompletionHandlerWithResult) {
//        if let organizationDict = self.dictionaryForOrganization(eventJson) {
//            
//            let organization = Organization(dictionary: organizationDict, context: self.sharedContext)
//            
//            completionHandler(success: true, result: organization, error: nil)
//        } else {
//            completionHandler(success: false, result: nil, error: Errors.constructError(domain: "Hacksmiths API Client", userMessage: "Unable to download information about the event organization"))
//        }
//    }
//    
//    func fetchEventAttendees(eventID: String, completionHandler: CompletionHandler) {
//        Alamofire.request(.GET, "https://hacksmiths.io/api/event/\(eventID)", parameters: nil, encoding: .URL, headers: nil)
//            .validate().responseJSON(completionHandler: {response in
//                
//                guard response.result.isSuccess else {
//                    completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
//                    return
//                }
//                
//                guard let value = response.result.value else {
//                    completionHandler(success: false, error: GlobalErrors.GenericNetworkError)
//                    return
//                }
//                
//                let jsonData = JSON(value)
//                
//                let eventId = jsonData[HacksmithsAPIClient.JSONResponseKeys.Event._id].string
//                let attendeesArray = jsonData[HacksmithsAPIClient.JSONResponseKeys.Event.attendees].arrayObject as? [JsonDict]
//                
//                
//                // Batch delete the RSVPs before creating new ones.
//                self.batchDeleteAllRSVPS({success, error in
//                    if error != nil {
//                        completionHandler(success: false, error: error)
//                    }
//                })
//                
//                // Loop through and create an RSVP record for each attendee.
//                for attendee in attendeesArray! {
//                    let personId = attendee["id"] as! String
//                    let eventRSVP = EventRSVP(personId: personId, eventId: eventId!, context: self.sharedContext)
//                    
//                }
//
//                // Save the context after creating the eventRSVPS.
//                self.sharedContext.performBlockAndWait({
//                    CoreDataStackManager.sharedInstance().saveContext()
//                })
//                
//                completionHandler(success: true, error: nil)
//        })
//    }
//    
//    private func batchDeleteAllRSVPS(completionHandler: CompletionHandler) {
//        let fetchRequest = NSFetchRequest(entityName: "EventRSVP")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: self.sharedContext)
//            sharedContext.performBlockAndWait({
//                CoreDataStackManager.sharedInstance().saveContext()
//            })
//            
//            completionHandler(success: true, error: nil)
//            
//        } catch let error as NSError {
//            completionHandler(success: false, error: error)
//        }
//    }
//    
//    private func batchDeleteAllEvents(completionHandler: CompletionHandler) {
//        let fetchRequest = NSFetchRequest(entityName: "Event")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: self.sharedContext)
//            sharedContext.performBlockAndWait({
//                CoreDataStackManager.sharedInstance().saveContext()
//            })
//            
//            completionHandler(success: true, error: nil)
//            
//        } catch let error as NSError {
//            completionHandler(success: false, error: error)
//        }
//    }
//
//    
//    /* Takes an event dictionary and returns a dictionary for creating an event */
//    private func dictionaryForEvent (eventJSON: JSON) -> JsonDict? {
//        print("Event JSON: \(eventJSON)")
//        let id = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.id].stringValue
//        let active = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.active].boolValue
//        let marketingInfo = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.marketingInfo].stringValue ?? ""
//        let title = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.title].stringValue
//        let description = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.description].stringValue ?? ""
//        let spotsRemaining = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.spotsRemaining].intValue ?? 0
//        
//        let registrationStartDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.registrationStartDate].stringValue ?? ""
//        let registrationEndDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.registrationEndDate].stringValue ?? ""
//        let startDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.starts].stringValue ?? ""
//        let endDateString = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.ends].stringValue ?? ""
//        
//        // Set up our dictionary
//        var dictionary: JsonDict = [
//            "id" : id,
//            "active" : active,
//            "marketingInfo": marketingInfo,
//            "title" : title,
//            "description" : description,
//            "spotsRemaining": spotsRemaining,
//        ]
//        
//        if let eventStartDate = dateFromString(registrationStartDateString) {
//            print("Creating date from string: \(registrationStartDateString)")
//            dictionary["registrationStartDate"] = eventStartDate
//        }
//        
//        if let eventEndDate = dateFromString(registrationEndDateString) {
//            dictionary["registrationEndDate"] = eventEndDate
//        }
//        
//        if let eventStartDate = dateFromString(startDateString), eventEndDate = dateFromString(endDateString) {
//            dictionary["starts"] = eventStartDate
//            dictionary["ends"] = eventEndDate
//        }
//        
//        if let featureImage = eventJSON[HacksmithsAPIClient.JSONResponseKeys.Event.featureImage].dictionary {
//            if let imageURL = featureImage["url"]!.string {
//                dictionary["featureImage"] = imageURL
//            }
//        }
//        
//        print("returning: \(dictionary)")
//        
//        return dictionary
//    }
//    
//    private func dictionaryForOrganization(eventJsonDict: JSON) -> JsonDict? {
//        var returnDict: JsonDict = [
//            "id": "",
//            "name": "",
//            "logoUrl": "",
//            "isHiring": false,
//            "website": "",
//            "about": ""
//        ]
//        
//        if let organization = eventJsonDict[HacksmithsAPIClient.JSONResponseKeys.Organization.dictKey].dictionary {
//            
//            // Check to make sure we got a good data object by checking the organization ID comes back as a value
//            guard let organizationID = organization[HacksmithsAPIClient.JSONResponseKeys.Organization._id]!.string else {
//                return nil
//            }
//            
//            let orgId = organizationID
//            let orgName = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.name]!.stringValue
//            let isHiring = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.isHiring]!.boolValue
//            
//            returnDict["id"] = orgId
//            returnDict["name"] = orgName
//            returnDict["isHiring"] = isHiring
//            
//            
//            if let logoURL = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.logo]![HacksmithsAPIClient.JSONResponseKeys.Organization.url].string {
//                returnDict["logoUrl"] = logoURL
//            }
//            
//            if let about = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.description]![HacksmithsAPIClient.JSONResponseKeys.Organization.md].string {
//                returnDict["about"] = about
//            }
//            
//            if let website = organization[HacksmithsAPIClient.JSONResponseKeys.Organization.website]!.string {
//                returnDict["website"] = website
//            }
//            
//        }
//        
//        print("Returning: \(returnDict)")
//        
//        return returnDict
//    }
//    
//    private func dateFromString(dateString: String) -> NSDate? {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ssZZZZZ"
//        let date = dateFormatter.dateFromString(dateString)
//        
//        return date
//    }
}