//
//  LeaderboardTableViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/22/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

class LeaderboardTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return leaderFetchResultsController.sections![section].numberOfObjects
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LeaderBoardTableViewCell", forIndexPath: indexPath) as! LeaderBoardTableViewCell
        

        
        return cell
    }
 
    
    lazy var leaderFetchResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "rank", ascending: true)
        
        let isPublicButNotLeaderPredicate = NSPredicate(format: "isPublic == %@ && isTopContributor == %@", NSNumber(bool: true), NSNumber(bool: false))
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
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        return false
    }


    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         Get the new view controller using segue.destinationViewController.
         Pass the selected object to the new view controller.
    }
    */

}
