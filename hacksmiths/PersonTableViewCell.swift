//
//  PersonTableViewCell.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/14/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    var person: Person? = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set the corner radius to make the image view circular
        personImageView?.layer.cornerRadius = personImageView!.frame.size.width / 2
        personImageView?.clipsToBounds = true
        personImageView?.layer.borderWidth = 3.0
        personImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
