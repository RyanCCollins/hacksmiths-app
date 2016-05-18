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

    @IBOutlet weak var organizationWebsiteButton: UIButton!
    @IBOutlet weak var organizationDescriptionLabel: UILabel!
    private let eventPresenter = EventPresenter(eventService: EventService())
    
    @IBOutlet weak var whenLabel: UILabel!
    var activityIndicator: IGActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUserInterface()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPresenter.attachView(self)
        startLoading()
    }
    
    
    func updateUserInterface() {
        
        
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
    
    func getEvent(didSucceed: Bool, event: Event){
        self.finishLoading()
        self.updateUserInterface()
    }
    
    func getEvent(didFail error: NSError) {
        
    }
    
    func setAttendees(forEvent event: Event) {
        
    }
    
    func respondToEvent(sender: EventPresenter, didSucceed event: Event) {
        
    }
    
    func respondToEvent(sender: EventPresenter, didFail error: NSError) {
        
    }
    
    
}
