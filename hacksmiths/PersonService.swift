//
//  PersonService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 6/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import PromiseKit

/** Person Service - responsible for getting API data for a person from the API.
 */
class PersonService {
    
    /** Get the member list from the API
     *
     *  @param None
     *  @return Promise<[Person?]> - a Promise of an array of person managed object
     */
    func getMemberList() -> Promise<[Person?]> {
        return Promise{resolve, reject in
            let method = Routes.Members
            syncInProgress = true
            HacksmithsAPIClient.taskForGETMethod(method, parameters: [:], completionHandler:CompletionHandler) {success, result, error in
                if error != nil {
                    reject(error)
                } else {
                    
                    if let membersArray = result["members"] as? [JsonDict] {
                        self.parseMemberArray(membersArray).then() {
                            people in
                            if people != nil {
                                /* Save the core data context finally */
                                GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                    CoreDataStackManager.sharedInstance().saveContext()
                                })
                                resolve(people)
                            } else {
                                reject()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /** Parse the member array returned from the API
     *
     *  @param memberArray - A dictionary containing the member data
     *  @return Promise<[Person]> - A promise of an array for the managed object model for person.
     */
    private func parseMemberArray(memberArray: [JsonDict]) -> Promise<[Person]> {
        return Promise{resolve, reject in
            let error: NSError? = nil
            let members: [Person] = memberArray.map{member in
                let person = Person(dictionary: member, context: GlobalStackManager.SharedManager.sharedContext)
                return person
            }
            for person in members {
                person.fetchImages().then() {
                    Void in
                    print("Successfully fetched images for all people.")
                    }.error {
                        error = error
                }
            }
            /* Determine if an error was thrown and resolve or reject the promise */
            if error != nil {
                reject(error)
            } else {
                resolve(members)
            }
        }
    }
    
}
