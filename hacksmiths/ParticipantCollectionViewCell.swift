//
//  ParticipantCollectionViewCell
//  hacksmiths
//
//  Created by Ryan Collins on 4/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

class ParticipantCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var participant: Participant!
    
    func setCellForParticipant(participant: Participant) {
        if let imageURL = participant.imageURLString {
            self.imageView.downloadedFrom(link: imageURL, contentMode: .Center)
        } else {
            imageView.image = UIImage(named: "avatar-missing")
        }
        
        self.nameLabel.text = participant.name
    }
}
