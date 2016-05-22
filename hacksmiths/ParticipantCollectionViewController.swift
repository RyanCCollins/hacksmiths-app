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
    var participants: [Participant]? = nil
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var currentEvent: Event?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.registerClass(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let participants = participants {
            return participants.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ParticipantCollectionViewCell
    
        // Configure the cell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ParticipantCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        if let participants = self.participants {
            let participant = participants[indexPath.row]
            cell.participant = participant
        }
    }
}

extension ParticipantCollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

    }
    
    
}


