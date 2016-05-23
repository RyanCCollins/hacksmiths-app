//
//  ParticipantCollectionViewCell
//  hacksmiths
//
//  Created by Ryan Collins on 4/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class ParticipantCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var nameLabel: UILabel!
    var participant: Participant!
    
    func setUIForPerson() {
        // Set the person's avatar to the missing person
        imageView.image = UIImage(named: "avatar-missing")
        
        // Set the person's image as long as it's not nil.
        if participant.image != nil {
            imageView.image = participant.image
        }
        if participant.imageURLString != nil {
            imageView.downloadedFrom(link: participant.imageURLString!, contentMode: .ScaleToFill)
        }
        nameLabel.text = participant.name
    }
}
