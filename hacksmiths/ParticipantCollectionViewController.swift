//
//  ParticipantCollectionViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ParticipantCollectionViewCell"

class ParticipantCollectionViewController: UICollectionViewController {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    private let participantPresenter = ParticipantPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
    }
    
    func setupCollectionView() {
        self.collectionView!.registerClass(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    /* Setup flowlayout upon layout of subviews */
    override func viewDidLayoutSubviews() {
        flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        let contentSize: CGFloat = ((collectionView!.bounds.width / 3) - 8)
        flowLayout.itemSize = CGSize(width: contentSize, height: contentSize)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        participantPresenter.attachView(self)
        subscribeToNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        participantPresenter.detachView(self)
        unsubscribeFromNotifications()
    }
    
    func didRecieveEventUpdate(){
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error:  \(error)")
        }
        collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let participants = fetchedResultsController.fetchedObjects as? [Participant] {
            print("Called collection view number of items with: \(participants.count)")
            return participants.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ParticipantCollectionViewCell
        if let participant = fetchedResultsController.fetchedObjects![indexPath.row] as? Participant {
            cell.setCellForParticipant(participant)
        }
        return cell
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let sortPriority = NSSortDescriptor(key: "name", ascending: true)
        let fetch = NSFetchRequest(entityName: "Participant")
        fetch.sortDescriptors = [sortPriority]

        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: GlobalStackManager.SharedManager.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        return fetchResultsController
    }()
}


extension ParticipantCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("Called controller did change content")
    }
}

extension ParticipantCollectionViewController {
    func subscribeToNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ParticipantCollectionViewController.didRecieveEventUpdate), name: "DidReceiveEventUpdate", object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension ParticipantCollectionViewController: ParticipantView {
    
    func didFetchParticipants(participants: [Participant]?) {

    }
    
    func noParticipantsFound() {
        
    }
}