//
//  PersonCollectionViewCell.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class PersonCollectionViewCell: UICollectionViewCell {
    var personImageView: UIImageView!
    var personNameLabel: UILabel!
    var person: Person!
    
    func setUIForPerson() {
        // Set the person's avatar to the missing person
        personImageView.image = UIImage(named: "avatar-missing")
        
        // Set the person's image as long as it's not nil.
        if person.image != nil {
            personImageView.image = person.image
        }
        personNameLabel.text = person.firstName + " " + person.lastName
    }
}
