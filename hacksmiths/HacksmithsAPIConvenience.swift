//
//  HacksmithsAPIConvenience.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

extension HacksmithsAPIClient {
    
    func checkService() {
        
    }
    
    func registerWithCredentials(username: String, password: String, completionHandler: CallbackHandler) {
        let method = Routes.SignupEmail
        
        let body = [Keys.Username: username, Keys.Password: password]
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {success, result, error in
            if error != nil {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                print(result)
                completionHandler(success: true, error: nil)
            }
            
        })
    }
    
    func authenticateWithCredentials(username: String, password: String, completionHandler: CallbackHandler) {
        let method = Routes.SigninEmail
        
        let body = [Keys.Username: username, Keys.Password: password]
        
        taskForPOSTMethod(method, JSONBody: body, completionHandler: {success, result, error in
            if error != nil {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                print(result)
                completionHandler(success: true, error: nil)
            }
            
        })
        
    }
    
    func getDataFromAPI(body: [String: AnyObject], completionHandler: CallbackHandler) {
        let method = Routes.Status
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            
            if error != nil {
                print(error)
            } else {
                print(result)
            }
            
        })
    }
    
    func getMemberList(body: [String :AnyObject], completionHandler: CallbackHandler) {
        let method = Routes.Members
        
        taskForGETMethod(method, parameters: body, completionHandler: {success, result, error in
            
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                
                if let membersArray = result[HacksmithsAPIClient.JSONResponseKeys.Members] as? [String : AnyObject] {
                    print(membersArray)
                }
                
            }
            
        })
    }
    
    
}
