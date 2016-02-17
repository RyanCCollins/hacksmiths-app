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
    
    func registerWithCredentials(username: String, body: [String: AnyObject], completionHandler: CallbackHandler) {
        let method = Routes.SignupEmail
        
        let postDict: [String: AnyObject] = [Keys.Username: username, Keys.Body: body]
        
        taskForPOSTMethod(method, JSONBody: postDict, completionHandler: {result, error in
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
        
        let postDict = [username: username, password: password]
        
        taskForPOSTMethod(method, JSONBody: postDict, completionHandler: {result, error in
            if error != nil {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                print(result)
                completionHandler(success: true, error: nil)
            }
            
        })
        
    }
    
}
