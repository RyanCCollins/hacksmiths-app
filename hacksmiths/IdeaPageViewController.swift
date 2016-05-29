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
    @IBOutlet weak var ideaSubmissionView: UIView!
    @IBOutlet weak var thanksView: UIView!
    var ideaExists = false
    
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
        submitAnIdea()
    }

}


extension IdeaPageViewController: IdeaPageView {
    func submitAnIdea() {
        if UserService.sharedInstance().authenticated == true {
            performSegueWithIdentifier("ShowIdeaSubmission", sender: self)
        } else {
            alertController(withTitles: ["OK"], message: "You must be logged in to submit an idea.  Please sign in or register to proceed.", callbackHandler: [nil])
        }
    }
    
    func editIdea() {
        
    }
    
    func showThanksView() {
        ideaSubmissionView.removeFromSuperview()
    }
    
    func showIdeaSubmissionView() {
        thanksView.removeFromSuperview()
    }
}

extension IdeaPageViewController: UIPopoverPresentationControllerDelegate {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentHelpSegue" {
            let popoverViewController = segue.destinationViewController as! HelpPageViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}