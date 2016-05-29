//
//  HelpPageViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/28/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class HelpPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        
        let firstHelpPage = storyboard?.instantiateViewControllerWithIdentifier("HelpLabelViewController") as! HelpLabelViewController
        let secondHelpPage = storyboard?.instantiateViewControllerWithIdentifier("HelpLabelViewController") as! HelpLabelViewController
        pages.append(firstHelpPage)
        pages.append(secondHelpPage)
        setViewControllers([firstHelpPage], direction: .Forward, animated: false, completion: nil)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.indexOf(viewController)!
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.indexOf(viewController)!
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
