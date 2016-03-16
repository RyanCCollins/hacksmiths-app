//
//  EventViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import SwiftyButton

class EventViewController: UIViewController {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var whoLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var registerSignupButton: SwiftyButton!

    @IBOutlet weak var whenLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getEventData()
    }
    
    func getEventData() {
        view.showLoading()
        HacksmithsAPIClient.sharedInstance().checkAPIForEvents({success, error in
            if error != nil {
                self.view.hideLoading()
                self.alertController(withTitles: ["OK"], message: (error?.localizedDescription)!, callbackHandler: [nil])
                
            } else {
                self.view.hideLoading()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
