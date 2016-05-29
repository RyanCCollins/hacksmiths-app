//
//  EnrollmentService.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/29/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import PromiseKit
import Gloss
import CoreData

class EnrollmentService: NSObject {
    func getAllNanodegrees() -> Promise<[Enrollment]?> {
        return Promise{resolve, reject in
            let router = EnrollmentRouter(endpoint: .GetAllNanodegrees())
            HTTPManager.sharedManager.request(router)
                .validate()
                .responseJSON{response in
                    
                    switch response.result {
                    case .Success(let JSON):
                        if let nanodegreeArray = JSON["nanodegrees"] as! [JSON] {
                            let enrollmentArry = EnrollmentJSON(json: nanodegreeArray)
                            let enrollments = createEnrollmentModel(enrollmentArry)
                        }

                    case .Failure(let error):
                        reject(error)
                    }
                    
                }
        }
    }
    
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
