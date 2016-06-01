//
//  HelpPageViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/28/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

/** Creates a paging help text popover for the idea submission view
 */
class HelpPageViewController: UIPageViewController {
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        
        let firstHelpPage = storyboard?.instantiateViewControllerWithIdentifier("HelpLabelViewController") as! HelpLabelViewController
        let secondHelpPage = storyboard?.instantiateViewControllerWithIdentifier("HelpLabelViewController") as! HelpLabelViewController
        let thirdHelpPage = storyboard?.instantiateViewControllerWithIdentifier("HelpLabelViewController") as! HelpLabelViewController
        let fourthHelpPage = storyboard?.instantiateViewControllerWithIdentifier("HelpLabelViewController") as! HelpLabelViewController
        firstHelpPage.helpLabelText = "1. Pick your favorite non-profit or philanthropic organization"
        secondHelpPage.helpLabelText = "2. Submit a detailed description, linking to a Google document if need be."
        thirdHelpPage.helpLabelText = "3. Stay tuned as we process the entries and decide on the best idea."
        fourthHelpPage.helpLabelText = "Email admin@hacksmiths.io with any questions."
        
        pages.append(firstHelpPage)
        pages.append(secondHelpPage)
        pages.append(thirdHelpPage)
        pages.append(fourthHelpPage)
        setViewControllers([firstHelpPage], direction: .Forward, animated: false, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.preferredContentSize = CGSizeMake(300, 200)
        super.viewWillAppear(animated)
    }
}

extension HelpPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    /** MARK: Delegate methods for paging
     */
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
