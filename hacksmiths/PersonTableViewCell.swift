//
//  PersonTableViewCell.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/14/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    let person: Person? = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
