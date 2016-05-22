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
    
    private var activityIndicator: IGActivityIndicatorView!
    private let communityPresenter = CommunityPresenter()
    var messageLabel = UILabel()
        
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
        let title = SectionTitle(rawValue: section)?.getTitle()
        if title != nil {
            return title
        } else {
            return nil
        }
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Initialize count with zero
        let sectionTitle = SectionTitle(rawValue: section)
        
        switch sectionTitle! {
        case .Leaders: return fetchedResultsController.fetchedObjects!.count
        case .Community: return communityFetchResultsController.fetchedObjects!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        var person: Person? = nil
        
        let sectionTitle = SectionTitle(rawValue: indexPath.section)
        
        switch sectionTitle! {
        case .Leaders:
            if let thePerson = fetchedResultsController.fetchedObjects![indexPath.row] as? Person {
                person = thePerson
            }
        case .Community:
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
        
        let section = SectionTitle(rawValue: indexPath.section)
        
        switch section! {
        case .Leaders:
            if let thePerson = fetchedResultsController.fetchedObjects![indexPath.row] as? Person {
                person = thePerson
            }
        case .Community:
            if let thePerson = communityFetchResultsController.fetchedObjects![indexPath.row] as? Person {
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
        startLoading()
        if error != nil {
            self.finishLoading()
            self.alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
        } else {
            self.refreshControl?.endRefreshing()
            self.performFetch()
            self.finishLoading()
            self.tableView.reloadData()
        }
    }
    
    func showNoDataLabel() {
        if tableView.numberOfRowsInSection(0) == 0 && tableView.numberOfRowsInSection(1) == 0 {
            messageLabel = UILabel(frame: CGRectMake(0,0, self.view.bounds.width, self.view.bounds.height))
            
            messageLabel.text = "No data is currently available, pull to refresh."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.font = UIFont(name: "Roboto", size: 20)
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .None
        } else {
            removeNoDataLabel()
        }
    }
    
    func removeNoDataLabel(){
        if view.subviews.contains(messageLabel) {
            messageLabel.removeFromSuperview()
        }
    }
    
}

enum SectionTitle: Int {
    case Leaders = 0, Community = 1
    
    func getTitle() -> String {
        switch self {
        case .Leaders:
            return "Leaders"
        case .Community:
            return "Community"
        }
    }
}
