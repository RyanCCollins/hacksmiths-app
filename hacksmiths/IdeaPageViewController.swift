//
//  IdeasViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/20/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class IdeaPageViewController: UIViewController {
    
    private let ideaPagePresenter = IdeaPagePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ideaPagePresenter.attachView(self)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ideaPagePresenter.detachView(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapSubmitIdeaUpInside(sender: AnyObject) {
        
        
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


extension IdeaPageViewController: IdeaPageView {
    func submitAnIdea() {
        if UserDefaults.sharedInstance().authenticated == true {
            
            performSegueWithIdentifier("ShowIdeaSubmission", sender: self)
            
        } else {
            alertController(withTitles: ["OK"], message: "You must be logged in to submit an idea.  Please sign in or register to proceed.", callbackHandler: [nil])
        }
    }
}