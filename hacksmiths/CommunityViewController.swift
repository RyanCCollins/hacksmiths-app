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
        configureRefreshControl()
        refreshDataFromAPI(self)
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: "refreshDataFromAPI:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    func refreshDataFromAPI(sender: AnyObject) {
        let body = [String : AnyObject]()
        
        
        HacksmithsAPIClient.sharedInstance().getMemberList(body, completionHandler: {result, error in
            
            if error != nil {
                
                self.alertController(withTitles: ["OK", "Retry"], message: "Sorry, but an error occured while downloading networked data.", callbackHandler: [nil, nil])
                
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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

        let fetchResultsController = NSFetchedResultsController(fetchRequest: leaderFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

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
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: isPublicButNotLeaderFetch, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
        return 2
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Leaders"
        }
        if section == 1 {
            return "Community"
        }
        return nil
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Initialize count with zero
        var count = 0
        if section == Sections.Leaders {
            count = (fetchedResultsController.fetchedObjects?.count)!

        }
        if section == Sections.Community {
            
            count = (communityFetchResultsController.fetchedObjects?.count)!
            
        }
        
        if count == 0 {
            let messageLabel = UILabel(frame: CGRectMake(0,0, self.view.bounds.width, self.view.bounds.height))
            messageLabel.text = "No data is currently available.  Please pull down to refresh."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.font = UIFont(name: "Roboto", size: 20)
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .None
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        
        var user: Person? = nil
        
        if indexPath.section == Sections.Leaders {
            if let person = fetchedResultsController.fetchedObjects![indexPath.row] as? Person {
                
                user = person
            }
        } else {
            
            if let person = communityFetchResultsController.fetchedObjects![indexPath.row] as? Person {
                user = person
            }
            
        }
        
        if user != nil {
            cell.person = user
            cell.personImageView.image = user!.image
            let name = user!.firstName + " " + user!.lastName
            cell.nameLabel.text = name
            cell.aboutLabel.text = user!.bio
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        let personView = storyboard?.instantiateViewControllerWithIdentifier("PersonViewController") as! PersonViewController
        let person = cell.person
        personView.person = person
        navigationController?.pushViewController(personView, animated: true)

    }
    
    

}

enum Sections {
    static let Leaders = 0
    static let Community = 1
}
