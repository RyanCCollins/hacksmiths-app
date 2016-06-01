//
//  AboutViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 3/21/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
/** About view controller, just informational
 */
class AboutViewController: UIViewController {
    
    @IBOutlet weak var ryanImageView: UIImageView!
    @IBOutlet weak var splashView: UIImageView!
    @IBOutlet weak var seanImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the image views to be circular
        setCircularImageView(ryanImageView)
        setCircularImageView(seanImageView)
        setupView()
    }
    
    func setupView() {
        splashView.frame = view.bounds
    }
    
    /** Open the hacksmiths.io about page
     */
    @IBAction func didTapHacksmithsUpInside(sender: AnyObject) {
        let url = NSURL(string: HacksmithsAPIClient.Constants.InfoPage)
        handleOpenURL(url!)
    }
    
    /** Set the images views as circular for Ryan and Sean
     */
    func setCircularImageView(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    /** Helper functions for opening URLS
     */
    @IBAction func didTapRyanTwitter(sender: AnyObject) {
        let url = NSURL(string: "https://twitter.com/ryancollinsio")
        handleOpenURL(url!)
    }
    
    @IBAction func didTapRyanGithub(sender: AnyObject) {
        let url = NSURL(string: "https://github.com/ryanccollins")
        handleOpenURL(url!)
    }
    
    @IBAction func didTapSeanGithub(sender: AnyObject) {
        let url = NSURL(string: "https://github.com/swhc1066")
        handleOpenURL(url!)
    }
    
    func handleOpenURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func didTapSeanTwitter(sender: AnyObject) {
        let url = NSURL(string: "https://twitter.com/seanwhcraig")
        handleOpenURL(url!)
    }
    
}
