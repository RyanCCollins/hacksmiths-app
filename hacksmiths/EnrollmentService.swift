//
//  EnrollmentService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import PromiseKit
import CoreData

/** Enrollment Service handles getting a payload of enrollments from API.
 *  This is not used in version 1, at least in the User Interface, but is needed for V2 and thus will stay.
 */
class EnrollmentService: NSObject {
    /** Get all nanodegrees from the API
     *
     *  @param None
     *  @return Promise<[Enrollment]?> - Promise of type array of core data managed enrollments (optional)
     */
    func getAllNanodegrees() -> Promise<[Enrollment]?> {
        return Promise{resolve, reject in
            let router = EnrollmentRouter(endpoint: .GetAllNanodegrees())
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON{response in
                    
                    switch response.result {
                    case .Success(let JSON):
                        
                        let nanodegreeArray = JSON["nanodegrees"] as! [JsonDict]
                        let enrollmentJSONArray = [EnrollmentJSON].fromJSONArray(nanodegreeArray)
                        let enrollments = self.createEnrollmentModel(enrollmentJSONArray)
                        resolve(enrollments)
                    case .Failure(let error):
                        reject(error)
                    }
                }
        }
    }
    
    /** Create the model for saving enrollments to core data
     *
     *  @param enrollmentJSONArray: [EnrollmentJSON] - An array returned from the server
     *  @return [Enrollment] - an array of the enrollment model saved to core data
     */
    func createEnrollmentModel(enrollmentJSONArray: [EnrollmentJSON]) -> [Enrollment]  {
        cleanupEnrollments()
        let enrollments = enrollmentJSONArray.map({enrollmentJSON in
            return Enrollment(enrollmentJSON: enrollmentJSON, context: GlobalStackManager.SharedManager.sharedContext)
        })
        GlobalStackManager.SharedManager.sharedContext.performBlockAndWait({
            CoreDataStackManager.sharedInstance().saveContext()
        })
        return enrollments
    }
    
    /** Cleanup enrollments - Takes care of deleting the managed object for Enrollment
     *
     *  @param None
     *  @return None
     */
    func cleanupEnrollments() {
        let fetchRequest = NSFetchRequest(entityName: "Enrollment")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try CoreDataStackManager.sharedInstance()
                .persistentStoreCoordinator?
                .executeRequest(deleteRequest, withContext: GlobalStackManager.SharedManager.sharedContext)
        } catch let error as NSError {
            print("Not much we can do about it now, but the delete request for enrollments failed in EventService with error: \(error)")
        }
    }
}
