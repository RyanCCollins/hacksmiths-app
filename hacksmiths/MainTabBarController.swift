//
//  MainTabBarController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/12/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import SwiftRaisedTab

class MainTabBarController: RaisedTabBarController {
    

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swapViewsForAuthenticatedState() {
        if UserData.sharedInstance().authenticated == true {
            self.tabBarController?.viewControllers
        }
    }
    
    func showLoginView(animated: Bool) {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//        window?.makeKeyAndVisible()
//        window?.rootViewController?.presentViewController(loginViewController, animated: animated, completion: nil)
        
    }
    
    func updateData() {
       
    }
    
    func logout() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let mainTabBarController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! MainTabBarController
//        window?.rootViewController = mainTabBarController
//        
//        showLoginView(true)
    }

}
