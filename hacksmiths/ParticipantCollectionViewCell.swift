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
    let missingImage = UIImage(named: "avatar-missing")
    
    func setCellForParticipant(participant: Participant) {
        if let imageURL = participant.imageURLString {
            self.imageView.downloadedFrom(link: imageURL, contentMode: .Center)
        } else {
            imageView.image = missingImage
        }
        
        self.nameLabel.text = participant.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set the corner radius to make the image view circular
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.image = missingImage
    }
}
