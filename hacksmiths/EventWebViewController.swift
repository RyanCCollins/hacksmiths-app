//
//  EventWebViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/12/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class EventWebViewController: UIViewController {
    @IBOutlet weak var eventWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let requestURL = NSURL(string: "http://hacksmiths.io/events/food-drivr-hackathon")
        let request = NSURLRequest(URL: requestURL!)
        eventWebView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
