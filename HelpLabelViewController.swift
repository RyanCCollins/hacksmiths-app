//
//  HelpLabelViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/28/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class HelpLabelViewController: UIViewController {

    var helpLabelText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var label = UILabel(frame: CGRectMake(0, 0, 200, 100))
        label.center = CGPointMake(150, 100)
        label.textAlignment = NSTextAlignment.Center
        label.text = "I'am a test label"
        self.view.addSubview(label)
    }

}
