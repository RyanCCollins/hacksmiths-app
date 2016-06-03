//
//  EventViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import SwiftyButton
import CoreData
/** Event View Controller
 *  Handles showing the current event and loading of a new event when there is one.
 */
class EventViewController: UIViewController {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var registerSignupButton: SwiftyButton!
    @IBOutlet weak var organizationImageView: UIImageView!
    @IBOutlet weak var organizationTitleLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var aboutEventStackView: UIStackView!
    @IBOutlet weak var eventInfoStackView: UIStackView!
    @IBOutlet weak var eventOrganizationHeaderStackView: UIStackView!
    @IBOutlet weak var eventOrganizationNotFoundLabel: UILabel!
    @IBOutlet weak var organizationWebsiteButton: UIButton!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    @IBOutlet weak var marketingInfoTextView: UITextView!
    @IBOutlet weak var marketingInfoStackView: UIStackView!
    @IBOutlet weak var participantHeaderStackView: UIStackView!
    @IBOutlet weak var noParticipantsLabel: UILabel!
    @IBOutlet weak var helpButtonView: UIView!
    
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    var currentEvent: Event?
    var activityIndicator: IGActivityIndicatorView!
    
    /** MARK: Life cycle methods
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setActivityIndicator()
        fetchedResultsController.delegate = self
        
        if currentEvent == nil {
            eventPresenter.fetchCachedEvent()
        } else {
            setupUserInterface(forEvent: currentEvent!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        eventPresenter.attachView(self)
        toggleButtonTitle(forAuthenticatedState: UserService.sharedInstance().authenticated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        eventPresenter.detachView()
    }
    
    func setActivityIndicator() {
        activityIndicator = IGActivityIndicatorView(inview: self.view)
    }
    
    /** When tapping refresh, start refreshing and check the API for new event data
     */
    @IBAction func didTapRefreshUpInside(sender: AnyObject) {
        startLoading()
        eventPresenter.fetchNextEvent()
    }
    
    /** Logic for setting event information UI
     *
     *  @params event: Event - the event that is loaded
     *  @return None
     */
    func setupUserInterface(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {

            self.eventImageView.image = event.image
            self.headerLabel.text = event.title
            
            self.aboutTextView.text = event.descriptionString
            self.whenLabel.text = event.formattedDateString
            
            if let place = event.place {
                self.whereLabel.text = place
            }
            self.collectionView.reloadData()
        })
        setupSectionOne(forEvent: event)
        setupOrganization(forEvent: event)
        setupMarketingInfo(forEvent: event)
        setupButton(forEvent: event)
        setButtonState(forEvent: event)
        setupParticipant(forEvent: event)
    }
    
    /** Setup the first section of the event page
     *
     *  @params event: Event - the event that is loaded
     *  @return None
     */
    func setupSectionOne(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {
            if let imageURL = event.featureImageURL {
                self.eventImageView.downloadedFrom(link: imageURL, contentMode: .ScaleAspectFit)
                self.eventImageView.fadeIn()
            }
            
            self.headerLabel.fadeIn()
            self.eventInfoStackView.fadeIn()
            self.aboutEventStackView.fadeIn()
            
        })
    }
    
    /** Setup the UI for the organization
     *
     *  @params event: Event - the event that is loaded
     *  @return None
     */
    func setupOrganization(forEvent event: Event) {
        if let organization = event.organization {
            if organization.image == nil && organization.logoUrl != nil {
                self.organizationImageView.downloadedFrom(link: organization.logoUrl!, contentMode: .ScaleAspectFit)
            } else if organization.image != nil {
                self.organizationImageView.image = organization.image
            }
            dispatch_async(GlobalMainQueue, {
                self.organizationTitleLabel.text = organization.name
                self.organizationDescriptionLabel.text = organization.descriptionString ?? ""
                
                if let website = organization.website {
                    self.organizationWebsiteButton.setTitle(website, forState: .Normal)
                }
            })
            
            self.showOrganizationUI(forEvent: event)
            
        } else {
            dispatch_async(GlobalMainQueue, {
                self.eventOrganizationNotFoundLabel.hidden = false
                self.eventOrganizationNotFoundLabel.fadeIn()
            })
        }
    }
    
    func showOrganizationUI(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {
            self.eventOrganizationHeaderStackView.fadeIn()
            self.organizationTitleLabel.fadeIn()
            self.organizationImageView.fadeIn()
            self.organizationDescriptionLabel.fadeIn()
            if event.organization?.website != nil {
                print("Calling create organization button")
                self.organizationWebsiteButton.hidden = false
                self.organizationWebsiteButton.fadeIn()
            }
        })
    }
    
    /** Setup the marketing section UI
     *
     *  @param event - the event we are currently concerned with
     *  @return None
     */
    func setupMarketingInfo(forEvent event: Event) {
        if let marketingInfo = event.marketingInfo {
            self.marketingInfoStackView.hidden = marketingInfo.isEmpty
            self.marketingInfoTextView.text = marketingInfo
            dispatch_async(GlobalMainQueue, {
                self.marketingInfoStackView.fadeIn()
            })
        }
    }
    
    /** Setup the register / sign up button based on the current event
     *
     *  @param event - the event we are concerned with
     *  @return None
     */
    func setupButton(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {
            self.registerSignupButton.fadeIn()
        })
    }
    
    /** Set the button state for the current event
     *
     *  @param event - the event we are concerned with
     *  @return None
     */
    func setButtonState(forEvent event: Event) {
        if event.active && event.spotsAvailable {
            registerSignupButton.enabled = true
        } else {
            registerSignupButton.enabled = false
        }
    }
    
    func toggleButtonTitle(forAuthenticatedState authenticated: Bool){
        if authenticated {
            registerSignupButton.setTitle("RSVP", forState: .Normal)
        } else {
            registerSignupButton.setTitle("SIGN IN", forState: .Normal)
        }
    }
    
    func setupParticipant(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {
            self.participantHeaderStackView.fadeIn()
        })
    }
    
    func resetUserInterface() {
        dispatch_async(GlobalMainQueue, {
            self.eventImageView.fadeOut()
            self.headerLabel.fadeOut()
            self.eventInfoStackView.fadeOut()

            self.participantHeaderStackView.fadeOut()
            self.aboutEventStackView.fadeOut()
            self.registerSignupButton.fadeOut()
            self.marketingInfoStackView.fadeOut()
            self.eventOrganizationHeaderStackView.fadeOut()
            
            self.eventOrganizationNotFoundLabel.fadeOut()
            self.organizationDescriptionLabel.fadeOut()
            self.organizationTitleLabel.fadeOut()
            self.organizationImageView.fadeOut()
            
            self.organizationWebsiteButton.fadeOut()
            self.participantHeaderStackView.fadeOut()
        })
    }
    
    /* Open the URL for the website if possible. */
    @IBAction func didTapOrganizationWebsiteButton(sender: UIButton) {
        if let urlString = sender.titleLabel?.text {
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    /** Show Help text in a popover view
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEventHelpPopover" {
            let eventHelpViewController = segue.destinationViewController as? EventHelpPopoverViewController
            eventHelpViewController?.helpText = "During an active event, you can RSVP to help us.  We will contact you to talk about your role in the project."
            eventHelpViewController?.popoverPresentationController?.delegate = self
            eventHelpViewController?.modalPresentationStyle = .Popover
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "name", ascending: true)
        let fetch = NSFetchRequest(entityName: "Participant")
        fetch.sortDescriptors = [sortPriority]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    func performParticipantFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func didTapRegisterUpInside(sender: AnyObject) {
        if UserService.sharedInstance().authenticated == true {
            if let currentEvent = currentEvent {
                eventPresenter.rsvpForEvent(currentEvent)
            }
        } else {
            performSegueWithIdentifier("ShowSignupToRegisterForEvent", sender: self)
        }
    }
}

extension EventViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
}

extension EventViewController: EventView {

    func startLoading() {
        print("Called start loading")
        self.activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        print("Called stop loading")
        self.activityIndicator.stopAnimating()
    }
    
    func didLoadCachedEvent(sender: EventPresenter, didSucceed event: Event?, error: NSError?) {
        print("Did load cached event")
        finishLoading()
        if error != nil {
            // Handle the error
            alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, { Void in
                self.eventPresenter.fetchCachedEvent()
            }])
        } else if event != nil {
            resetUserInterface()
            setupUserInterface(forEvent: event!)
            performParticipantFetch()
            currentEvent = event
        } else {
            /** No Event cached.  Fetch the event. */
            self.eventPresenter.fetchNextEvent()
        }
    }
    
    func didReceiveNewEvent(sender: EventPresenter, didSucceed event: NextEvent?, error: NSError?) {
        finishLoading()
        if error != nil || event == nil {
            let message = error?.localizedDescription ?? "An unknown error occurred."
            alertController(withTitles: ["OK"], message: message, callbackHandler: [nil])
        } else {
            self.eventPresenter.fetchEventData(event!.idString)
        }
    }
    
    /** Did receive event data - called when the full event's data has been loaded
     *
     *  @param Sender - the event presenter sending the message
     *  @param didSucceed event - the event that was loaded if successful
     *  @param didFail error - the error that was received if the request failed
     *  @return None
     */
    func didReceiveEventData(sender: EventPresenter, didSucceed event: Event?, didFail error: NSError?) {
        finishLoading()
        if event != nil {
            resetUserInterface()
            currentEvent = event
            performParticipantFetch()
            setupUserInterface(forEvent: event!)
        } else if error != nil  {
            alertController(withTitles: ["OK", "Retry"], message: error!.localizedDescription, callbackHandler: [nil, {Void in
                /* Retry fetching the next event if error received*/
                self.eventPresenter.fetchNextEvent()
            }])
        }
    }
    
    func didRSVPForEvent(sender: EventPresenter, success: Bool, error: NSError?) {
        if error != nil {
            self.alertController(withTitles: ["OK"], message: (error?.localizedDescription)!, callbackHandler: [nil])
        } else {
            self.alertController(withTitles: ["No thanks", "Sign up for Slack"], message: "Thanks for helping!  Join us on slack and we'll see if we can find a place for you!", callbackHandler: [nil, {Void in
                    self.openSlackNow()
            }])
        }
    }
    
    func openSlackNow() {
        let urlString = "https://hacksmiths-slack-invite.herokuapp.com/"
        let slackUrl = NSURL(string: urlString)
        UIApplication.sharedApplication().openURL(slackUrl!)
    }
    
}

extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    /** Get the participants for a specific event
     *
     *  @param None
     *  @return [Participant] - an array optional participants for the curren event
     */
    func getEventParticipants(event: Event) -> [Participant]? {
        var eventParticipants: [Participant]?
        if let participants = fetchedResultsController.fetchedObjects as? [Participant] {
            eventParticipants = participants.filter({participant in
                return participant.event == event
            })
        }
        return eventParticipants != nil ? eventParticipants : nil
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /* Return 0 if there is no current event for whatever reason */
        guard let event = currentEvent else {
            return 0
        }
        
        if let participants = getEventParticipants(event) {
            return participants.count > 0 ? participants.count : 0
        } else {
            return 0
        }
    }
    
    /** Collection view delegate method for setting cell at indexPath for participant
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ParticipantCollectionViewCell", forIndexPath: indexPath) as! ParticipantCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    /** Configure participant cell - handles configuring the cell for each participant
     *
     *  @param cell - the cell to configure
     *  @param indexPath - the index path where we are setting the participant
     *  @return None
     */
    func configureCell(cell: ParticipantCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let event = currentEvent else {
            return
        }
        
        if let eventParticipants = getEventParticipants(event) {
            /* Dealing with the bug where the indexPaths were not matching count*/
            if eventParticipants.count >= indexPath.row {
                let participant = eventParticipants[indexPath.row]
                cell.setCellForParticipant(participant)
            }
        }
    }
}

enum EventStatus {
    case Previous, Current
}

extension EventViewController: UIPopoverPresentationControllerDelegate {
    /** Used to create the popover view for the iPhone.
     */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
