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
    @IBOutlet weak var whoLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var registerSignupButton: SwiftyButton!
    @IBOutlet weak var organizationImageView: UIImageView!
    @IBOutlet weak var organizationTitleLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var aboutEventStackView: UIStackView!
    @IBOutlet weak var eventInfoStackView: UIStackView!
    @IBOutlet weak var eventOrganizationHeaderStackView: UIStackView!
    @IBOutlet weak var organizationWebsiteButton: UIButton!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    @IBOutlet weak var marketingInfoTextView: UITextView!
    @IBOutlet weak var marketingInfoStackView: UIStackView!
    @IBOutlet weak var participantHeaderStackView: UIStackView!
    
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    var currentEvent: Event?
    var activityIndicator: IGActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        eventPresenter.attachView(self)
        setActivityIndicator()
        eventPresenter.fetchAndCheckAPIForEvent()
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
        self.eventPresenter.fetchAndCheckAPIForEvent()
    }
    
    func updateUserInterface(forEvent event: Event) {
        
        dispatch_async(GlobalMainQueue, {

            self.eventImageView.image = event.image
            self.headerLabel.text = event.title
            
            self.aboutTextView.text = event.descriptionString
            self.whenLabel.text = event.formattedDateString
            
            self.collectionView.reloadData()
        })
        setupSectionOne(forEvent: event)
        setupOrganization(forEvent: event)
        setupMarketingInfo(forEvent: event)
        setupButton(forEvent: event)
        setupParticipant(forEvent: event)
    }
    
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
            if let image = organization.image,
                let descriptionString = organization.descriptionString,
                let organizationWebsite = organization.website {
                self.organizationImageView.image = image
                self.organizationDescriptionLabel.text = descriptionString
                self.organizationTitleLabel.text = organization.name
                self.organizationWebsiteButton.titleLabel!.text = organizationWebsite
                self.whoLabel.text = organization.name
                self.showOrganizationUI(forEvent: event)
            }
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
    
    func setupParticipant(forEvent event: Event) {
        dispatch_async(GlobalMainQueue, {
            if event.active == true {
                
            }
            self.participantHeaderStackView.fadeIn()
        })
    }
    
    func setParticipantHeader(forEvent: Event) {
    
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
        }
    }
}

extension EventViewController: EventView {

    func startLoading() {
        self.activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        self.activityIndicator.stopAnimating()
    }
    
    func didLoadCachedEvent(event: Event) {
        finishLoading()
        self.currentEvent = event
        updateUserInterface(forEvent: event)
    }
    
    func didReceiveNewEvent(sender: EventPresenter, newEvent: NextEvent?, error: NSError?) {
        finishLoading()
        if error != nil || newEvent == nil {
            let message = error?.localizedDescription ?? "An unknown error occurred."
            alertController(withTitles: ["OK"], message: message, callbackHandler: [nil])
        } else {
            startLoading()
            self.eventPresenter.getEventData(newEvent!.idString)
        }
    }
    
    
    func didReceiveEventData(sender: EventPresenter, didSucceed event: Event?, didFail error: NSError?) {
        finishLoading()
        if event != nil {
            currentEvent = event
            performParticipantFetch()
            updateUserInterface(forEvent: event!)
        } else if error != nil  {
            alertController(withTitles: ["OK", "Retry"], message: error!.localizedDescription, callbackHandler: [nil, {Void in
            return
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
