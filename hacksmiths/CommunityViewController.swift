//
//  CommunityViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class CommunityViewController: UITableViewController {
    
    private var activityIndicator: IGActivityIndicatorView!
    private let communityPresenter = CommunityPresenter()
    let searchController = UISearchController(searchResultsController: nil)
    var searchPredicate: NSPredicate? = nil
    let isLeaderPredicate = NSPredicate(format: "isLeader == %@ && isPublic == %@", NSNumber(bool: true), NSNumber(bool: true))
    
    var messageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set this view to be the fetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
        configureRefreshControl()
        self.communityPresenter.attachView(self)
        self.communityPresenter.fetchCommunityMembers()
        setupSearchContoller()
    }
    
    /* Setup the search controller on view load */
    func setupSearchContoller() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    /* Configure the refresh control for pulling to refresh */
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
        let fetch = NSFetchRequest(entityName: "Person")
        fetch.sortDescriptors = [sortPriority]
        
        fetch.predicate = self.isLeaderPredicate
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

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
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: isPublicButNotLeaderFetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
}
/* Core data fetched results controller delegate methods */
extension CommunityViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
}


/* Extension for UITableViewDataSource and Delegate methods */
extension CommunityViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate != nil {
            return 1
        } else {
            return 2
        }
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "Community Members"
        if searchPredicate != nil {
            title = (SectionTitle(rawValue: section)?.getTitle())!
        }
        return title
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate != nil {
            return fetchedResultsController.fetchedObjects!.count
        } else {
            // Initialize count with zero
            let sectionTitle = SectionTitle(rawValue: section)
            
            switch sectionTitle! {
            case .Leaders: return fetchedResultsController.fetchedObjects!.count
            case .Community: return communityFetchResultsController.fetchedObjects!.count
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTableViewCell") as! PersonTableViewCell
        var person: Person? = nil
        if searchPredicate != nil {
            if let thePerson = fetchedResultsController.fetchedObjects![indexPath.row] as? Person {
                person = thePerson
            }
        } else {
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
        }
        let configuredCell = configureCell(cell, withPerson: person)
        return configuredCell!
    }
    
    func configureCell(cell: PersonTableViewCell, withPerson person: Person?) -> PersonTableViewCell? {
        guard person != nil else {
            return nil
        }
        
        if person!.image != nil {
            cell.personImageView.image = person!.image
        }
        cell.nameLabel.text = person!.fullName
        cell.aboutLabel.text = person!.bio
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
            messageLabel.font = UIFont(name: "Open Sans", size: 20)
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
    
    func filterResultsForSearch(searchText: String, scope: String = "All") {
        if searchText.length > 0 {
            /* Hack: Search by either first name or both first and last */
            let fullName = searchText
            var firstName = ""
            var lastName = ""
            var searchPredicate: NSPredicate!
            if searchText.rangeOfString(" ") != nil {
                let fullNameArray = fullName.componentsSeparatedByString(" ")
                firstName = fullNameArray.count > 0 ? fullNameArray.first! : ""
                lastName = fullNameArray.count >= 1 ? fullNameArray.last! : ""
            } else {
                firstName = searchText
            }
            searchPredicate = NSPredicate(format: "firstName contains[c] %@ && lastName contains[c] %@ && isPublic == %@", firstName, lastName, NSNumber(bool: true))
            fetchedResultsController.fetchRequest.predicate = searchPredicate
            self.performFetch()
            tableView.reloadData()
        }
    }
    
}

extension CommunityViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if let searchText = searchText {
            filterResultsForSearch(searchText)
        } else {
            cancelSearch(searchController.searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancelSearch(searchBar)
    }
    func cancelSearch(searchbar: UISearchBar) {
        searchbar.resignFirstResponder()
        searchbar.text = ""
        searchPredicate = nil
        fetchedResultsController.fetchRequest.predicate = isLeaderPredicate
        self.performFetch()
        tableView.reloadData()
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
