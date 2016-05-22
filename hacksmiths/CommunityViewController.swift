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
    
    private var activityIndicator: IGActivityIndicatorView!
    private let communityPresenter = CommunityPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set this view to be the fetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
        configureRefreshControl()
        self.communityPresenter.attachView(self)
        self.communityPresenter.fetchCommunityMembers()
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchNetworkData), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        self.activityIndicator = IGActivityIndicatorView(inview: view)
    }
    
    
    func fetchNetworkData() {
        self.communityPresenter.fetchCommunityMembers()
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
        
        var person: Person? = nil
        
        if indexPath.section == Sections.Leaders {
            if let thePerson = fetchedResultsController.fetchedObjects![indexPath.row] as? Person {
                person = thePerson
            }
        } else {
            
            if let thePerson = communityFetchResultsController.fetchedObjects![indexPath.row] as? Person {
                person = thePerson
            }
            
        }
        
        if person != nil {
            cell.person = person
            
            // Set the default image if the user is missing an image
            if person!.image == nil {
                cell.personImageView.image = UIImage(named: "avatar-missing")
            } else {
              cell.personImageView.image = person!.image
            }
            
            cell.nameLabel.text = person?.fullName
            cell.aboutLabel.text = person!.bio
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var person: Person? = nil
        
        if indexPath.section == Sections.Leaders {
            if let thePerson = fetchedResultsController.objectAtIndexPath(indexPath) as? Person {
                person = thePerson
            }
        } else if indexPath.section == Sections.Community {
            if let thePerson = communityFetchResultsController.objectAtIndexPath(indexPath) as? Person {
                person = thePerson
            }
        }
        
        if person != nil {
            let personView = storyboard?.instantiateViewControllerWithIdentifier("PersonViewController") as! PersonViewController
            personView.person = person
            
            navigationController?.pushViewController(personView, animated: true)
        } else {
            alertController(withTitles: ["OK"], message: "It looks like that person has deleted their profile.", callbackHandler: [nil])
        }
    }
}

extension CommunityViewController: CommunityView {
    func startLoading() {
        activityIndicator.startAnimating()
    }
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
    
    func fetchCommunity(sender: CommunityPresenter, didSucceed: Bool, didFailWithError error: NSError?) {
        if error != nil {
            self.alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
        } else {
            
            self.refreshControl?.endRefreshing()
            self.performFetch()

            self.tableView.reloadData()
            
        }
    }
    
}

enum Sections {
    static let Leaders = 0
    static let Community = 1
}
