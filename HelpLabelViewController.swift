//
//  HelpLabelViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/28/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class HelpLabelViewController: UIViewController {

    @IBOutlet weak var helpLabel: UILabel!
    var helpLabelText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helpLabel.text = helpLabelText
    }
    
    func setLabelText(text: String) {
        helpLabelText = text
    }
    

}
