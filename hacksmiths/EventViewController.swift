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
import Foundation

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
    
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    var currentEvent: Event?
    var activityIndicator: IGActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        eventPresenter.attachView(self)
        setActivityIndicator()
        if currentEvent == nil {
            eventPresenter.fetchCachedEvent()
        } else {
            setupUserInterface(forEvent: currentEvent!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        toggleButtonTitle(forAuthenticatedState: UserService.sharedInstance().authenticated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        eventPresenter.detachView()
    }
    
    func setActivityIndicator() {
        activityIndicator = IGActivityIndicatorView(inview: self.view)
    }
    
    @IBAction func didTapRefreshUpInside(sender: AnyObject) {
        startLoading()
        eventPresenter.fetchNextEvent()
    }
    
    /** Logic for setting event information UI
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
                self.organizationWebsiteButton.titleLabel!.text = organization.website ?? ""
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
                self.organizationWebsiteButton.hidden = false
            }
        })
    }
    
    func setupMarketingInfo(forEvent event: Event) {
        if let marketingInfo = event.marketingInfo {
            self.marketingInfoStackView.hidden = marketingInfo.isEmpty
            self.marketingInfoTextView.text = marketingInfo
            dispatch_async(GlobalMainQueue, {
                self.marketingInfoStackView.fadeIn()
            })
        }
    }
    
    func setupButton(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {
            self.registerSignupButton.fadeIn()
        })
    }
    
    func setButtonState(forEvent event: Event) {
        if event.active && event.spotsAvailable {
            registerSignupButton.enabled = true
        } else {
            registerSignupButton.enabled = false
        }
    }
    
    func toggleButtonTitle(forAuthenticatedState authenticated: Bool){
        if authenticated {
            registerSignupButton.titleLabel!.text = "I WANT TO HELP!"
        } else {
             registerSignupButton.titleLabel!.text = "SIGN IN TO HELP!"
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
        print("Did receive new event")
        finishLoading()
        if error != nil {
            let message = error?.localizedDescription ?? "An unknown error occurred."
            alertController(withTitles: ["OK"], message: message, callbackHandler: [nil])
        } else if event != nil{
            self.eventPresenter.fetchEventData(event!.idString)
        } else {
            /* No change */
        }
    }
    
    func didReceiveEventData(sender: EventPresenter, didSucceed event: Event?, didFail error: NSError?) {
        print("Did receive event data")
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
    
    func handleSetDebugMessage(message: String) {
        print("Set debug message: \(message)")
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

extension EventViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
}

extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func getEventParticipants() -> [Participant]? {
        var eventParticipants: [Participant]?
        if let participants = fetchedResultsController.fetchedObjects as? [Participant] {
            eventParticipants = participants.filter({participant in
                return participant.event == currentEvent
            })
        }
        return eventParticipants != nil ? eventParticipants : nil
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let participants = getEventParticipants() {
            return participants.count > 0 ? participants.count : 0
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ParticipantCollectionViewCell", forIndexPath: indexPath) as! ParticipantCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ParticipantCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        if let eventParticipants = getEventParticipants() {
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
