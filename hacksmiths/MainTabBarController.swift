//
//  MainTabBarController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/12/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor(hex: "#7ACFF0")

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if the user is authenticated and swap the views if so.
        swapViewsForAuthenticatedState()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swapViewsForAuthenticatedState() {

        if UserData.sharedInstance().authenticated == true {
            let profileViewController = storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController")
            var viewControllers = tabBarController?.viewControllers
            viewControllers?.removeFirst()
            viewControllers?.insert(profileViewController!, atIndex: 0)
            tabBarController?.setViewControllers(viewControllers, animated: true)
        } 
    }

}
