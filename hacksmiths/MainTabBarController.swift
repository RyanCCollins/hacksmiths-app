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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
