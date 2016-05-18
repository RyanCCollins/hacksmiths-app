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
    @IBOutlet weak var organizationWebsiteStackView: UIStackView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var whoLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var registerSignupButton: SwiftyButton!
    @IBOutlet weak var organizationImageView: UIImageView!
    @IBOutlet weak var organizationTitleLabel: UILabel!

    @IBOutlet weak var organizationWebsiteButton: UIButton!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    @IBOutlet weak var whenLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    
    private func updateUserInterface() {
        if let event = currentEvent {
            eventImageView.image = event.image
            headerLabel.text = event.title
            
            if let organization = event.organization {
                organizationImageView.image = organization.image
                organizationTitleLabel.text = organization.name
                organizationDescriptionLabel.text = organization.about ?? ""
                
                if let organizationImage = organization.image {
                    organizationImageView.image = organizationImage
                } else {
                    organizationImageView.image = UIImage(named: "missing-visual")
                }
                
                if let website = organization.website {
                    organizationWebsiteStackView.hidden = false
                    organizationWebsiteButton.titleLabel!.text = website
                } else {
                    /* Hide the entire stack view if there is no website. */
                    organizationWebsiteStackView.hidden = true
                }
                
            }
        }
    }
    
    private func setButtonForAuthState() {
        if UserDefaults.sharedInstance().authenticated == true {
            
            registerSignupButton.enabled = true
            
        } else {
            registerSignupButton.enabled = false
        }
    }
    

    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "startDate", ascending: false)
        let nextEventFetch = NSFetchRequest(entityName: "Event")
        nextEventFetch.sortDescriptors = [sortPriority]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: nextEventFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    /* Open the URL for the website if possible. */
    @IBAction func didTapOrganizationWebsiteButton(sender: UIButton) {
        if let urlString = sender.titleLabel?.text {
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func performEventFetch() {
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            self.alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                self.performEventFetch()
            }])
        }
    }

    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

}

extension EventViewController: EventView {
    func startLoading() {
        
    }
    
    func finishLoading() {
        
    }
    
    func setEvent(didSucceed: Bool, event: Event){
        
    }
    
    func setEvent(didFail error: NSError) {
        
    }
    
    func setAttendees(forEvent event: Event) {
        
    }
    
    func respondToEvent(sender: EventPresenter, didSucceed event: Event) {
        
    }
    
    func respondToEvent(sender: EventPresenter, didFail error: NSError) {
        
    }
    
    
}
