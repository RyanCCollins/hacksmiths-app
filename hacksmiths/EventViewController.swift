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

class EventViewController: UIViewController {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var whoLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var registerSignupButton: SwiftyButton!
    @IBOutlet weak var organizationImageView: UIImageView!
    @IBOutlet weak var organizationTitleLabel: UILabel!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    var currentEvent: Event?
    
    @IBOutlet weak var whenLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getEventData()
    }
    
    func getEventData() {
        
        HacksmithsAPIClient.sharedInstance().fetchEventsFromAPI({success, error in
            if error != nil {
                
                self.alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in self.getEventData()}])
                
            } else {
                
                // Start loading the event data and then pass off loading of the event attendees.
                self.performEventFetch()
                
                
                if let event = self.fetchedResultsController.fetchedObjects![0] as? Event {
                    self.currentEvent = event
                }
                self.updateUIWithNetworkData(self.currentEvent)
            }
        })
    }
    
    func updateUIWithNetworkData(event: Event?) {
        if let event = event {
            eventImageView.image = event.image
            headerLabel.text = event.title
            aboutTextView.text = event.descriptionString
        }
        
        if let organization = currentEvent?.organization {
            whoLabel.text = organization.name
            
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
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
