//
//  AboutViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var ryanImageView: UIImageView!

    @IBOutlet weak var seanImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the image views to be circular
        setCircularImageView(ryanImageView)
        setCircularImageView(seanImageView)
        
    }
    
    // Open the hacksmiths.io about page
    @IBAction func didTapHacksmithsUpInside(sender: AnyObject) {
        let url = NSURL(string: HacksmithsAPIClient.Constants.InfoPage)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func setCircularImageView(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    @IBAction func didTapRyanTwitter(sender: AnyObject) {
        let url = NSURL(string: "https://twitter.com/ryancollinsio")
        UIApplication.sharedApplication().openURL(url!)
    }
    @IBAction func didTapRyanGithub(sender: AnyObject) {
        let url = NSURL(string: "https://github.com/ryanccollins")
        UIApplication.sharedApplication().openURL(url!)
    }
    
}
