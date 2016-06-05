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
     *  @param - None
     *  @return - Promise<Void> - a Promise that the core data model has been saved
     */
    func getMemberList() -> Promise<Void> {
        return Promise{resolve, reject in
            let method = HacksmithsAPIClient.Routes.Members
            HacksmithsAPIClient.sharedInstance().taskForGETMethod(method, parameters: [:]) {success, result, error in
                if error != nil {
                    reject(error!)
                } else {
                    if let membersArray = result["members"] as? [JsonDict] {
                        self.parseMemberArray(membersArray).then() {
                            people -> () in

                                /* Save the core data context finally */
                                GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
                                    CoreDataStackManager.sharedInstance().saveContext()
                                })
                                resolve()
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
    private func parseMemberArray(memberArray: [JsonDict]) -> Promise<[Person?]> {
        return Promise{resolve, reject in
            let members: [Person] = memberArray.map{member in
                let person = Person(dictionary: member, context: GlobalStackManager.SharedManager.sharedContext)
                return person
            }
            resolve(members)
        }
    }
    
    /** Promise of image fetching for the members.
     *
     *  @param
     *  @return
     */
    func fetchImages(forPeople people: [Person]) -> Promise<AnyObject> {
        var promise: Promise<AnyObject> = Promise<AnyObject>("Promise")
        for person in people {
            promise = promise.then() {_ in
                return Promise{resolve, reject in
                    person.fetchImages().then(){
                        resolve()
                    }
                }
            }
        }
        return promise
    }
}
