//
//  CommunityViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData
import SwiftSpinner

class CommunityViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set this view to be the fetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
        syncNetworkData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func syncNetworkData() {
        let body = [String : AnyObject]()
//        SwiftSpinner.showWithDelay(1.0, title: "Loading").addTapHandler({
//            SwiftSpinner.hide()
//        })
        HacksmithsAPIClient.sharedInstance().getMemberList(body, completionHandler: {result, error in
            
            if error != nil {

                self.alertController(withTitles: ["OK", "Retry"], message: "Sorry, but an error occured while downloading networked data.", callbackHandler: [nil, nil])
                
            } else {
                self.tableView.reloadData()
            }
            
        })
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
        tableView.reloadData()
    }
    
    /* Perform our fetch with the fetched results controller */
    func performFetch() {
        
        do {
            
            try self.fetchedResultsController.performFetch()
            try self.communityFetchResultsController.performFetch()
            
        } catch let error as NSError {
            self.alertController(withTitles: ["OK", "Retry"], message: error.localizedDescription, callbackHandler: [nil, {Void in
                self.performFetch()
                }])
        }
        
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
 
        let sortPriority = NSSortDescriptor(key: "sortPriority", ascending: true)
        
        // Leader fetch for getting team leaders
        // Set predicate to equal isPublic and isLeader both true
        let isLeaderPredicate = NSPredicate(format: "isLeader == %@ && isPublic == %@", NSNumber(bool: true), NSNumber(bool: true))
        let leaderFetch = NSFetchRequest(entityName: "Person")
        leaderFetch.predicate = isLeaderPredicate
        leaderFetch.sortDescriptors = [sortPriority]
        

        
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: leaderFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: "Leaders", cacheName: nil)

        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
    
    lazy var communityFetchResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "sortPriority", ascending: true)
        
        let isPublicButNotLeaderPredicate = NSPredicate(format: "isPublic == %@ && isLeader == %@", NSNumber(bool: true), NSNumber(bool: false))
        let isPublicButNotLeaderFetch = NSFetchRequest(entityName: "Person")
        isPublicButNotLeaderFetch.sortDescriptors = [sortPriority]
        isPublicButNotLeaderFetch.predicate = isPublicButNotLeaderPredicate
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: isPublicButNotLeaderFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: "Community", cacheName: nil)
        
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
        // Set count to 0
        var count = 0
        /* Increment the count by the number of sections in the first FRC */
        if let sections = fetchedResultsController.sections?.count {
            count += sections
        }
        
        /* Increment the count by the number of sections in the community */
        if let communitySections = communityFetchResultsController.sections?.count {
            count += communitySections
        }
        
        return count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        
        cell.personImageView.image = UIImage(contentsOfFile: "person")
        
        if let user = fetchedResultsController.fetchedObjects![indexPath.section] as? Person {
            //cell.personImageView.image = user.image
            let name = user.firstName + " " + user.lastName
            cell.nameLabel.text = name
            cell.aboutLabel.text = user.bio
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        let profileView = storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        if let person = cell.person {
            profileView.person = person
            navigationController?.pushViewController(profileView, animated: true)
        }
    }

}

enum Sections {
    
}
