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
    private let personService = PersonService()
    
    /** MARK: Lifecycle
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this view to be the fetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
        self.activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Loading")
        configureRefreshControl()
        self.communityPresenter.attachView(self, personService: personService)
        self.communityPresenter.fetchCommunityMembers()
        setupSearchContoller()
    }
    
    /** Setup the search controller on view load
     */
    func setupSearchContoller() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    /** Configure the refresh control for pulling to refresh
     */
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchNetworkData), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    /** Set the search controller to be not active when the segue occurs
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchController.active = false
    }
    
    /** Convenience for fetching the data from pull to refresh control
     */
    func fetchNetworkData() {
        self.communityPresenter.fetchCommunityMembers()
    }
    
    /** Perform our fetch with the fetched results controllers
     */
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
    
    /** Fetched results controller number 1 for leaders, or when searching
     */
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
    
    /** Fetched results controller number 2 for community members only
     */
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
/** Core data fetched results controller delegate methods
 */
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


/** Extension for UITableViewDataSource and Delegate methods
 */
extension CommunityViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate != nil {
            return 1
        } else {
            return 2
        }
    }
    
    /** Avoid having the section insets for tableview
     */
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    /** Title for headers in table view
     */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String!
        if searchPredicate == nil {
            /* If the predicate is nil, then set the title based on which section we are in */
            title = (SectionTitle(rawValue: section)?.getTitle())!
        } else {
            title = "All Members"
        }
        return title
    }
    
    /** Return the number of items in each section based on the items in the Fetched Results Controller.
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Initialize count with zero
            let sectionTitle = SectionTitle(rawValue: section)
            
            switch sectionTitle! {
            case .Leaders:
                return searchPredicate == nil ? fetchedResultsController.fetchedObjects!.count : 0
                
            case .Community:
                /* If the search predicate is not nil, then we are only concerned with the one section
                 * So return 0, otherwise return the community fetch
                 */
                return searchPredicate == nil ? communityFetchResultsController.fetchedObjects!.count : 0
        }
    }
    
    /** Match a person with the tableview and setup the cell to match the person
     */
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
    
    /** Configure the cell for the person
     *
     *  @param cell: PersonTableViewCell - the cell being configured
     *  @param person: Person? the person being used to define the data for the cell
     *  @return PersonTableViewCell? - the tableviewcell for the person.
     */
    func configureCell(cell: PersonTableViewCell, withPerson person: Person?) -> PersonTableViewCell? {
        guard person != nil else {
            return nil
        }
        
        cell.showImage(person!.image)
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
            
            /* Set the search controller to not be active*/
            searchController.active = false
            navigationController?.pushViewController(personView, animated: true)
        } else {
            alertController(withTitles: ["OK"], message: "It looks like that person has deleted their profile.", callbackHandler: [nil])
        }
    }
}

/** Extension for following the MVP pattern for the Community view
 */
extension CommunityViewController: CommunityView {
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
    
    /** Fetch the community members - Protocol method for updating the view when the people are fetched
     *
     *  @param sender - the sender of the method
     *  @param didSucceed - Bool whether the fetch succeeded or not
     *  @param didFailWithError: NSError - an error if it failed
     *  @return None
     */
    func fetchCommunity(sender: CommunityPresenter, didSucceed: Bool, didFailWithError error: NSError?) {
        finishLoading()
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
}

extension CommunityViewController {
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
    
    /** Filter the search results for the given search text
     *
     *  @param searchText: String - the text entered into the search bar
     *  @param scope - Defaults to ALl - the scope of the search
     *  @return None
     */
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
                searchPredicate = NSPredicate(format: "firstName contains[c] %@ && lastName contains[c] %@ && isPublic == %@", firstName, lastName, NSNumber(bool: true))
            } else {
                firstName = searchText
                searchPredicate = NSPredicate(format: "firstName contains[c] %@ && isPublic == %@", firstName, NSNumber(bool: true))
            }
            
            fetchedResultsController.fetchRequest.predicate = searchPredicate
            self.performFetch()
            tableView.reloadData()
        }
    }
}

/** Community View Controller extension for UISearchBar Delegation
 */
extension CommunityViewController: UISearchResultsUpdating, UISearchBarDelegate {
    /** Update the search results from the search results controller
     *
     *  @param searchController - the controller sending the message
     *  @return None
     */
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

/** Enumeration for the section titles for each section
 */
enum SectionTitle: Int {
    case Leaders = 0, Community
    
    /** Get the title for the section in string format
     *
     *  @param None
     *  @return - String - the string represenation for the section title.
     */
    func getTitle() -> String {
        switch self {
        case .Leaders:
            return "Leaders"
        case .Community:
            return "Community"
        }
    }
}
