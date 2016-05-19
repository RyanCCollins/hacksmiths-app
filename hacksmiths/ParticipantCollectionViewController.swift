//
//  ParticipantCollectionViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PersonTableViewCell"

class ParticipantCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var currentEvent: Event?
    var needsNewAttendees = true
    var people: [Person]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.registerClass(PersonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if needsNewAttendees {
            fetchEventAttendees()
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
        //        return self.fetchedResultsController.sections?.count ?? 0
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
//        let sectionInfo = fetchedResultsController.sections![section]
//        return sectionInfo.numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
    
        // Configure the cell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: PersonCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
//        if let person = fetchedResultsController.fetchedObjects![indexPath.row] as? Person {
//            cell.person = person
//            cell.setUIForPerson()
//        }
    }
    
    func fetchEventAttendees() {
//        guard let eventId = self.currentEvent?.eventID else {
//            return
//        }
//        
//        HacksmithsAPIClient.sharedInstance().fetchEventAttendees(eventId, completionHandler: {success, error in
//            if error != nil {
//                self.view.hideLoading()
//                self.alertController(withTitles: ["OK", "Retry"], message: (error?.localizedDescription)!, callbackHandler: [nil, {Void in self.fetchEventAttendees()}])
//            } else {
//                self.view.hideLoading()
//                self.performEventFetch()
//            }
//        })
    }
    
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        var eventId = ""
//        if self.currentEvent != nil {
//            eventId = self.currentEvent!.eventID
//        }
//        let rsvpFetch = NSFetchRequest(entityName: "EventRSVP")
//        let eventPredicate = NSPredicate(format: "%K == %@", "event.eventId", eventId)
//        rsvpFetch.sortDescriptors = []
//        
//        let fetchResultsController = NSFetchedResultsController(fetchRequest: rsvpFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//        
//        do {
//            try fetchResultsController.performFetch()
//        } catch let error {
//            print(error)
//        }
//
//        return fetchResultsController
//    }()
    
//    func performEventFetch() {
//        do {
//            
//            try fetchedResultsController.performFetch()
//            
//        } catch let error as NSError {
//            self.alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
//                self.performEventFetch()
//                }])
//        }
//    }
    
}

extension ParticipantCollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

    }
    
    
}


