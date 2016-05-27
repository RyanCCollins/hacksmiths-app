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
    
    @IBOutlet weak var organizationWebsiteButton: UIButton!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    var currentEvent: Event?
    var activityIndicator: IGActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        eventPresenter.attachView(self)
        eventPresenter.loadNextEvent()
        updateUserInterface()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        eventPresenter.fetchNextEvent()
        setActivityIndicator()
        startLoading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        eventPresenter.detachView()
    }
    
    func setActivityIndicator() {
        activityIndicator = IGActivityIndicatorView(inview: self.view)
    }
    
    @IBAction func didTapRefreshUpInside(sender: AnyObject) {
        
    }
    
    func updateUserInterface() {
        if let event = currentEvent {
            /* Set the UI elements on the main queue */
            dispatch_async(GlobalMainQueue, {
                if let imageURL = event.featureImageURL {
                    self.eventImageView.downloadedFrom(link: imageURL, contentMode: .ScaleAspectFit)
                }
                self.eventImageView.image = event.image
                self.headerLabel.text = event.title
                self.aboutTextView.text = event.descriptionString
                self.aboutTextView.textColor = UIColor.whiteColor()
                
                self.whenLabel.text = event.formattedDateString
                self.aboutTextView.text = event.descriptionString
                
                if let organization = self.currentEvent?.organization {
                    if let image = organization.image,
                       let descriptionString = organization.descriptionString,
                       let organizationWebsite = organization.website {
                        self.organizationImageView.image = image
                        self.organizationDescriptionLabel.text = descriptionString
                        self.organizationTitleLabel.text = organization.name
                        self.organizationWebsiteButton.titleLabel!.text = organizationWebsite
                        self.organizationWebsiteButton.hidden = false
                        self.whoLabel.text = organization.name
                    }
                }
            })
        }
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

}

extension EventViewController: EventView {

    func startLoading() {
        self.activityIndicator.startAnimating()
    }
    
    
    func finishLoading() {
        self.activityIndicator.stopAnimating()
    }
    
    func didReceiveNextEvent(sender: EventPresenter, nextEvent: NextEvent?, error: NSError?) {
        if error != nil || nextEvent == nil {
            let message = error?.localizedDescription ?? "An unknown error occurred."
            alertController(withTitles: ["OK"], message: message, callbackHandler: [nil])
        } else {
            let nextEventId = nextEvent?.idString
            self.eventPresenter.getEventData(nextEventId!)
        }
    }
    
    func getEvent(sender: EventPresenter, didSucceed event: Event) {
        self.currentEvent = event
        self.finishLoading()
        self.updateUserInterface()
        performParticipantFetch()
        collectionView.reloadData()
    }
    
    func getEvent(sender: EventPresenter, didFail error: NSError) {
        print("Called getEvent:didFail in EventView with error: \(error)")
        
        self.finishLoading()
        alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
            self.eventPresenter.fetchNextEvent()
        }])
    }
    
    func respondToEvent(sender: EventPresenter, didSucceed event: Event) {
        self.currentEvent = event
        self.finishLoading()
        updateUserInterface()
    }
    
    func respondToEvent(sender: EventPresenter, didFail error: NSError) {
    
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ParticipantCollectionViewCell", forIndexPath: indexPath) as! ParticipantCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ParticipantCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let participant = fetchedResultsController.objectAtIndexPath(indexPath) as! Participant
        cell.setCellForParticipant(participant)
    }
    
}
