//
//  CommunityViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class CommunityViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var userList = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set this view to be the fetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Show loading indicator while performing fetch */
    func performInitialFetch() {
        sharedContext.performBlockAndWait({
            self.performFetch()
        })
        dispatch_async(GlobalMainQueue, {
            self.configureDisplay()
        })
    }

    func configureDisplay() {
        
    }
    
    /* Perform our fetch with the fetched results controller */
    func performFetch() {
        
        do {
            
            try self.fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            self.alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                self.performFetch()
                }])
        }
        
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetch = NSFetchRequest(entityName: "User")
        let roleSort = NSSortDescriptor(key: "role.title", ascending: true)
        let lastNameSort = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetch.sortDescriptors = [roleSort, lastNameSort]
        
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

}


/* Extension for UITableViewDataSource and Delegate methods */
extension CommunityViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections?.count {
            return sections
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        
        cell.personImageView.image = UIImage(contentsOfFile: "person")
        
        if let user = fetchedResultsController.fetchedObjects![indexPath.section] as? User {
            cell.personImageView.image = user.image
            cell.nameLabel.text = user.name
            cell.aboutLabel.text = user.about
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profileView = storyboard?.instantiateInitialViewController()
    }

}
