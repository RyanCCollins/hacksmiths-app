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
    private let participantPresenter = ParticipantPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.registerClass(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        participantPresenter.attachView(self)
        
        subscribeToNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        participantPresenter.detachView(self)
    }
    
    func didRecieveEventUpdate(){
        participantPresenter.getParticipants()
        collectionView?.reloadData()
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
            cell.setUIForPerson()
        }
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
        if let participants = participants {
            self.participants = participants
            self.collectionView?.reloadData()
        } else {
            
        }
    }
    
    func noParticipantsFound() {
        
    }
}