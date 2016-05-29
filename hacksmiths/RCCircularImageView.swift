//
//  RCCircularImageView
//  hacksmiths
//
//  Created by Ryan Collins on 5/2/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
@IBDesignable

// Built with a bit of help from: http://www.sitepoint.com/creating-custom-ui-components-live-rendering-xcode/
class RCCircularImageView: UIView {
    
    var backgroundLayer: CAShapeLayer!
    var imageLayer: CALayer!
    var userImage: UIImage?
    
    @IBInspectable var image: UIImage?
    
    @IBInspectable var backgroundLayerColor: UIColor = UIColor.whiteColor()
    @IBInspectable var lineWidth: CGFloat = 1.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBackgroundLayer()
        setBackgroundImageLayer()
        setImage()
    }
    
    func setBackgroundLayer() {
        if backgroundLayer == nil {
            backgroundLayer = CAShapeLayer()
            layer.addSublayer(backgroundLayer)
            let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
            let path = UIBezierPath(ovalInRect: rect)
            backgroundLayer.path = path.CGPath
            backgroundLayer.lineWidth = lineWidth
            backgroundLayer.fillColor = backgroundLayerColor.CGColor
        }
        backgroundLayer.frame = layer.bounds
    }
    
    func setBackgroundImageLayer() {
        
        if imageLayer == nil {
            let mask = CAShapeLayer()
            let dx = lineWidth + 3.0
            let path = UIBezierPath(ovalInRect: CGRectInset(self.bounds, dx, dx))
            mask.fillColor = UIColor.blackColor().CGColor
            mask.path = path.CGPath
            mask.frame = self.bounds
            layer.addSublayer(mask)
            imageLayer = CAShapeLayer()
            imageLayer.frame = self.bounds
            imageLayer.mask = mask
            imageLayer.contentsGravity = kCAGravityResizeAspectFill
            layer.addSublayer(imageLayer)
        }
        
    }

    func setImage() {
        if imageLayer != nil {
            if let userPicture = userImage {
                imageLayer.contents = userPicture.CGImage
            } else {
                if let picture = image {
                    imageLayer.contents = picture.CGImage
                }
            }
        }
        
    }
    
}