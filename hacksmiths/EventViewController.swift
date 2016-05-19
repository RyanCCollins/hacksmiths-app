//
//  EventViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import SwiftyButton
import CoreData
import Foundation

class EventViewController: UIViewController {
    @IBOutlet weak var organizationWebsiteStackView: UIStackView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var whoLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var registerSignupButton: SwiftyButton!
    @IBOutlet weak var organizationImageView: UIImageView!
    @IBOutlet weak var organizationTitleLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    
    @IBOutlet weak var organizationWebsiteButton: UIButton!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    var currentEvent: Event?
    
    var activityIndicator: IGActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUserInterface()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPresenter.attachView(self)
        eventPresenter.getNextEvent()
        startLoading()
    }
    
    
    func updateUserInterface() {
        if let event = currentEvent {
            
            /* Set the UI elements on the main queue */
            dispatch_async(GlobalMainQueue, {
                self.eventImageView.image = event.image
                self.headerLabel.text = event.title
                self.aboutTextView.text = event.descriptionString
                
                self.whenLabel.text = "Set date here"
                self.whoLabel.text = "Set who here"
                
                if let organization = self.currentEvent?.organization {
                    if let image = organization.image,
                       let descriptionString = organization.descriptionString,
                       let organizationWebsite = organization.website {
                        self.organizationImageView.image = image
                        self.organizationDescriptionLabel.text = descriptionString
                        self.organizationWebsiteButton.titleLabel!.text = organizationWebsite
                        self.organizationWebsiteButton.hidden = false
                    }
                }
            })
        }
    }
    
    
    private func setButtonForAuthState() {
        if UserDefaults.sharedInstance().authenticated == true {
            
            registerSignupButton.enabled = true
            
        } else {
            registerSignupButton.enabled = false
        }
    }
    
    
    /* Open the URL for the website if possible. */
    @IBAction func didTapOrganizationWebsiteButton(sender: UIButton) {
        if let urlString = sender.titleLabel?.text {
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }

}

extension EventViewController: EventView {


    func startLoading() {
        self.activityIndicator.startAnimating()
    }
    
    
    func finishLoading() {
        self.activityIndicator.stopAnimating()
    }
    
    func getEvent(sender: EventPresenter, didSucceed event: Event) {
        self.currentEvent = event
        self.finishLoading()
        self.updateUserInterface()
        print("Called getEvent:didSucceed in EventView with event: \(event)")
    }
    
    func getEvent(sender: EventPresenter, didFail error: NSError) {
        print("Called getEvent:didFail in EventView with error: \(error)")
    }
    
    func respondToEvent(sender: EventPresenter, didSucceed event: Event) {
        
    }
    
    func respondToEvent(sender: EventPresenter, didFail error: NSError) {
    
    }
    
    
}
