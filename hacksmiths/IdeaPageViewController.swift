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
    private var eventService: EventService?
    @IBOutlet weak var ideaSubmissionView: UIView!
    @IBOutlet weak var thanksView: UIView!
    private var currentEvent: NextEvent?
    var ideaExists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventService = EventService()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ideaPagePresenter.attachView(self, eventService: self.eventService!)
        ideaPagePresenter.loadCurrentEvent()
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
        if currentEvent != nil {
            submitAnIdea(ideaPagePresenter)
        } else {
            alertController(withTitles: ["OK"], message: "Idea submission is only open when there is an active event.  Please check back later.", callbackHandler: [nil])
        }
    }
}

/** Extension for MVP idea submission Model View Presenter view delegate methods.
 */
extension IdeaPageViewController: IdeaPageView {
    /** Submit an idea through the idea page presenter delegate method.
     *
     *  @param sender - the presenter sending the message
     *  @return None
     */
    func submitAnIdea(sender: IdeaPagePresenter) {
        if UserService.sharedInstance().authenticated == true {
            performSegueWithIdentifier("ShowIdeaSubmission", sender: self)
        } else {
            alertController(withTitles: ["OK"], message: "You must be logged in to submit an idea.  Please sign in or register to proceed.", callbackHandler: [nil])
        }
    }
    
    /** Called from the presenter when the next event is loaded
     *
     *  @param sender - The presenter sending the message.
     *  @param didSucceed with nextEvent model - An optional NextEvent showing the id and status of the event.
     *  @param didFail with Error - An optional error that can be sent if the request fails.
     *  @return
     */
    func didLoadNextEvent(sender: IdeaPagePresenter, didSucceed nextEvent: NextEvent?, didFail error: NSError?) {
        if error != nil {
            alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
        } else if nextEvent != nil {
            currentEvent = nextEvent
        } else {
            /* Check the API for the event*/
            ideaPagePresenter.checkAPIForEvent()
        }
    }
}

extension IdeaPageViewController: UIPopoverPresentationControllerDelegate {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentHelpSegue" {
            let popoverViewController = segue.destinationViewController as! HelpPageViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
        
        /** If the idea submission segue is called, pass the current event in
         *  NOTE: If the current event is nil for some reason, then this will allow
         *  The segue.  The current event needs to be located before ever calling the segue.
         */
        if segue.identifier == "ShowIdeaSubmission" {
            if currentEvent != nil {
                let ideaSubmissionViewController = segue.destinationViewController as! IdeaSubmissionViewController
                ideaSubmissionViewController.currentEvent = currentEvent!
            }
        }
    }
    
    /** Set the adaptive presentation style to allow for poover view on iPhone.
     */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}