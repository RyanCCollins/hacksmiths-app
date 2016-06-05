//
//  CommunityViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData
/** Show the hacksmiths community members in the table view controller
 */
class CommunityViewController: UITableViewController {
    
    private var activityIndicator: IGActivityIndicatorView!
    private let communityPresenter = CommunityPresenter()
    let searchController = UISearchController(searchResultsController: nil)
    /** Various predicates for the fetched results controller
     */
    private var searchPredicateLeader: NSPredicate? = nil
    private var searchPredicateCommunity: NSPredicate? = nil
    private let isLeaderPredicate = NSPredicate(format: "isLeader == %@ && isPublic == %@", NSNumber(bool: true), NSNumber(bool: true))
    private let isNotLeaderPredicate = NSPredicate(format: "isPublic == %@ && isLeader == %@", NSNumber(bool: true), NSNumber(bool: false))
    private let personService = PersonService()
    
    /** MARK: Lifecycle
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Loading")
        configureRefreshControl()
        self.communityPresenter.fetchCommunityMembers()
        setupSearchContoller()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.communityPresenter.attachView(self, personService: personService)
        /** Set the status bar to default so that it shows over the light view
         */
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        /** Set the status bar back to white when leaving the view
         */
        self.communityPresenter.detachView(self)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    /** Setup the search controller on view load
     */
    private func setupSearchContoller() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    /** Configure the refresh control for pulling to refresh
     */
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchNetworkData), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    /** Convenience for fetching the data from pull to refresh control
     */
    func fetchNetworkData() {
        startLoading()
        self.communityPresenter.fetchCommunityMembers()
    }
    
    /** Perform our fetch with the fetched results controllers for leaders and community
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
    
    /** Fetched results controller number 1 for leaders section
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
        
        let isPublicButNotLeaderFetch = NSFetchRequest(entityName: "Person")
        isPublicButNotLeaderFetch.sortDescriptors = [sortPriority]
        isPublicButNotLeaderFetch.predicate = self.isNotLeaderPredicate
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: isPublicButNotLeaderFetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
}


/** Extension for UITableViewDataSource and Delegate methods
 */
extension CommunityViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    /** Avoid having the section insets for tableview
     */
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    /** Title for headers in table view.  Maps to enumeration value for section titles
     */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = (SectionTitle(rawValue: section)?.getTitle())!
        return title
    }
    
    /** Return the number of items in each section based on the items in the Fetched Results Controller.
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Initialize the section title based on the section number passed in
            let sectionTitle = SectionTitle(rawValue: section)
            switch sectionTitle! {
            case .Leaders:
                return fetchedResultsController.fetchedObjects!.count
            case .Community:
                return communityFetchResultsController.fetchedObjects!.count
        }
    }
    
    /** Match a person with the tableview and setup the cell to match the person
     */
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
        dispatch_async(GlobalMainQueue, {
            cell.showImage(person!.image)
            cell.setNeedsLayout()
            cell.nameLabel.text = person!.fullName
            cell.aboutLabel.text = person!.bio
        })
        return cell
    }
    
    /** Tableview delegate method for selecting rows.  Selects a person and shows the person view
     *
     *  @param tableView - the tableview sending the message
     *  @param indexPath - the indexPath of the row selected on the Table View
     *  @return None
     */
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
            
            /* Clear out the search so everything looks fine when returning*/
            cancelSearch(searchController.searchBar)
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
        dispatch_async(GlobalMainQueue, {
            self.activityIndicator.startAnimating()
        })
    }
    func finishLoading() {
        dispatch_async(GlobalMainQueue, {
            self.activityIndicator.stopAnimating()
        })
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
    
    /** Filter the search results for the given search text
     *
     *  @param searchText: String - the text entered into the search bar
     *  @param scope - Defaults to ALl - the scope of the search
     *  @return None
     */
    func filterResultsForSearch(searchText: String, scope: String = "All") {
        /* Hack: Search by either first name or both first and last */
        let fullName = searchText
        var firstName = ""
        var lastName = ""
        if searchText.rangeOfString(" ") != nil {
            let fullNameArray = fullName.componentsSeparatedByString(" ")
            firstName = fullNameArray.count > 0 ? fullNameArray.first! : ""
            lastName = fullNameArray.count >= 1 ? fullNameArray.last! : ""
            searchPredicateLeader = NSPredicate(format: "firstName contains[c] %@ && lastName contains[c] %@ && isPublic == %@ && isLeader == %@", firstName, lastName, NSNumber(bool: true), NSNumber(bool: true))
            searchPredicateCommunity = NSPredicate(format: "firstName contains[c] %@ && lastName contains[c] %@ && isPublic == %@ && isLeader == %@", firstName, lastName, NSNumber(bool: true), NSNumber(bool: false))
        } else {
            firstName = searchText
            searchPredicateLeader = NSPredicate(format: "firstName contains[c] %@ && isPublic == %@ && isLeader == %@", firstName, NSNumber(bool: true), NSNumber(bool: true))
            searchPredicateCommunity = NSPredicate(format: "firstName contains[c] %@ && isPublic == %@ && isLeader == %@", firstName, NSNumber(bool: true), NSNumber(bool: false))
        }
        
        fetchedResultsController.fetchRequest.predicate = searchPredicateLeader
        communityFetchResultsController.fetchRequest.predicate = searchPredicateCommunity
        self.performFetch()
        tableView.reloadData()
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
        if searchText != nil && searchText?.characters.count > 0 {
            filterResultsForSearch(searchText!)
        }
    }
    
    /** Text did change delegate method for determining when the text has been deleted
     *
     *  @param searchBar - the search bar that had the text changed
     *  @param searchText - the text in the search bar.
     *  @return None
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == true {
            cancelSearch(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancelSearch(searchBar)
    }
    
    /** Cancel the search when the cancel button is tapped or when the text is empty
     *
     *  @param searchBar = the search bar sending the event
     *  @return None
     */
    func cancelSearch(searchbar: UISearchBar) {
        searchbar.resignFirstResponder()
        searchController.active = false
        searchbar.text = ""
        searchPredicateLeader = nil
        searchPredicateCommunity = nil
        fetchedResultsController.fetchRequest.predicate = isLeaderPredicate
        communityFetchResultsController.fetchRequest.predicate = isNotLeaderPredicate
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
