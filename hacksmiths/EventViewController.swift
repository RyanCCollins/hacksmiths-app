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

    @IBOutlet weak var whenLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getEventData()
    }
    
    func getEventData() {
        HacksmithsAPIClient.sharedInstance().checkAPIForEvents({success, error in
            if error != nil {
                self.view.hideLoading()
                self.alertController(withTitles: ["OK"], message: (error?.localizedDescription)!, callbackHandler: [nil])
                
            } else {

                self.performEventFetch()
            }
        })
    }
    
    func updateUIWithNetworkData() {
        if let event = fetchedResultsController.fetchedObjects![0] as? Event {
            
            eventImageView.image = event.image
            headerLabel.text = event.title
            whoLabel.text = event.organization
            aboutTextView.text = event.descriptionString
            
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
