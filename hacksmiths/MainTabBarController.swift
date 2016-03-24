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
        
        // Call the swap views for authenticated state when first loaded to avoid any situation where the
        // View would not show.
        swapViewsForAuthenticatedState()
    }
    
    // Run a check for swapping the view when a tabbar item is selected.
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        swapViewsForAuthenticatedState()
    }
    
    
    // Checks if the user is authenticated and sets the proper tab bar items based
    // If they are authenticated, they should not see the JoinViewController
    // If they are not authenticated, they should not see the ProfileViewController.
    func swapViewsForAuthenticatedState() {

        if UserDefaults.sharedInstance().authenticated == true {
            print("User is authenticated")
            let profileViewController = storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            
            // Make sure that the first view controller does not contain the joinviewcontroller
            if viewControllers!.first is JoinViewController {
                print("attempting to swap out the first view controller\(viewControllers!.first)")
                viewControllers?.removeFirst()
                viewControllers?.insert(profileViewController, atIndex: 0)
                tabBarController?.setViewControllers(viewControllers, animated: false)
            }
            

        } else {
            
            print("User is not authenticated")
            let joinViewController = storyboard?.instantiateViewControllerWithIdentifier("JoinViewController") as! JoinViewController
            
            
            // Remove the first element if it is profile view controller
            if viewControllers!.first is ProfileViewController {
                viewControllers?.removeFirst()
                viewControllers?.insert(joinViewController, atIndex: 0)
                tabBarController?.setViewControllers(viewControllers, animated: false)
            }
            

        }
    }

}
