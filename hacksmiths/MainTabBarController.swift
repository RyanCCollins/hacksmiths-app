//
//  MainTabBarController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/12/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    /** MARK: Lifecycle methods
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor(hex: "#3291c9")
        
        // Call the swap views for authenticated state when first loaded to avoid any situation where the view would not show
        swapViewsForAuthenticatedState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        swapViewsForAuthenticatedState()
    }
    
    /** Run a check for swapping the view when a tabbar item is selected.
    */
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        swapViewsForAuthenticatedState()
    }
    
    /** Checks if the user is authenticated and sets the proper tab bar items based
     *  If they are authenticated, they should not see the JoinViewController
     *  If they are not authenticated, they should not see the ProfileViewController.
     */
    func swapViewsForAuthenticatedState() {
        if UserService.sharedInstance().authenticated == true {
            let profileViewController = storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            if viewControllers!.first is JoinViewController {
                print("attempting to swap out the first view controller\(viewControllers!.first)")
                viewControllers?.removeFirst()
                viewControllers?.insert(profileViewController, atIndex: 0)
                tabBarController?.setViewControllers(viewControllers, animated: false)
            }
        } else {
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

extension MainTabBarController {
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
