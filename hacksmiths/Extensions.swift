//
//  ExtendsUIViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 1/23/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import Spring
import Foundation

/**
 Publicly available extensions to abstract away commonly used
 functionality
 **/

class ExtendsUIViewController: UIViewController {
    func minimizeView(sender: AnyObject) {
        SpringAnimation.spring(0.7, animations: {
            self.view.transform = CGAffineTransformMakeScale(0.935, 0.935)
        })
    }
    
    func maximizeView(sender: AnyObject) {
        SpringAnimation.spring(0.7, animations: {
            self.view.transform = CGAffineTransformMakeScale(1, 1)
        })
    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
}

extension UIViewController {
    /** Helper function for utilizing an alert controller.
     
      @param titles: An array of strings to set the titles of the alert controller items
      @param message: A single string to show as the title for the alert controller
      @param callbackHandlers: an array of functions to call on button press, matches the order of the actions.
      @return None
     */
    func alertController(withTitles titles: [String], message: String, callbackHandler: [((UIAlertAction)->Void)?]) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .ActionSheet)
        for title in titles.enumerate() {
            if let callbackHandler = callbackHandler[title.index] {
                let action = UIAlertAction(title: title.element, style: .Default, handler: callbackHandler)
                alertController.addAction(action)
            } else {
                let action = UIAlertAction(title: title.element, style: .Default, handler: nil)
                alertController.addAction(action)
            }
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

/** Commonly used UIView extensions
 */
extension UIView {
    /** Fade In any view
     *
     *  @param Duration: NSTimeInterval - duration of animation
     *  @param Delay: NSTimeInterval - the delay of the animation
     *  @param Alpha: Float - the alpha to animate to
     *  @param Completion Handler - the completion handler to be called after completion
     *  @return None - Uses a completion handler to define when the 
     */
    func fadeIn(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, alpha: CGFloat = 1.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)
    }
    
    /** Fade out any view
     *
     *  @param Duration: NSTimeInterval - duration of animation
     *  @param Delay: NSTimeInterval - the delay of the animation
     *  @param Alpha: Float - the alpha to animate to
     *  @param Completion Handler - the completion handler to be called after completion
     *  @return None - Uses a completion handler to define when the
     */
    func fadeOut(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, endAlpha alpha: CGFloat = 0.2, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)
    }
    
    /** Transform a view in when it has been transformed out (scale)
     *
     *  @param sender - the sender of the event
     *  @param transformationScale - the scale to transform in from
     *  @return None
     */
    func transformIn(sender: AnyObject, transformationScale scale: (CGFloat, CGFloat) = (0.935, 0.935)) {
        SpringAnimation.spring(0.7, animations: {
            self.transform = CGAffineTransformMakeScale(1, 1)
        })
    }
    
    /** Transform a view out in scale (used in the settings view
     *
     *  @param sender - the sender of the event
     *  @param transformationScale - the scale to transform out from
     *  @return None
     */
    func transformOut(sender: AnyObject, transformationScale scale: (CGFloat, CGFloat) = (0.935, 0.935)) {
        SpringAnimation.spring(0.7, animations: {
            self.transform = CGAffineTransformMakeScale(scale)
        })
    }
}

/* Extension for parsing a string as a date */
extension String {
    
    /** Parse a string as a date in a format that the API will understand
     */
    func parseAsDate() -> NSDate? {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let date = dateFormatter.dateFromString(self) {
            return date
        } else {
            return nil
        }
    }
    
    /** Remove HTML and special characters from string
     */
    func stringByRemovingHTML() -> String {
        let noHTMLString = self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        let cleanedString = noHTMLString.removeSpecialCharacters()
        let returnString = cleanedString.removeNBSP()
        return returnString
    }
    
    /** Remove the NBSP from text characters retrieved from the API
     */
    private func removeNBSP() -> String {
        let noNBSPString = self.stringByReplacingOccurrencesOfString("nbsp", withString: " ")
        return noNBSPString
    }
    
    /**
     *
     *  @param
     *  @return
     */
    private func removeSpecialCharacters() -> String {
        let chars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(self.characters.filter { chars.contains($0) })
    }
    
}

/** Handy extensions for parsing dates through monkey patching
 */
extension NSDate {
    func parseAsString() -> String? {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.stringFromDate(self)
        return date
    }
}

/** Extensions to UIImageView
 * FROM: http://stackoverflow.com/questions/9786018/loading-an-image-into-uiimage-asynchronously
 */
extension UIImageView {
    /** Download an image from an image view
     *
     *  @param link - the link to use to download the image from
     *  @param mode - the content mode for the image
     *  @return None
     */
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard let url = NSURL(string: link) else {
            return
        }
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}

/* Added to help bridge the gap for finding the last path component in Swift
 Referenced from here: https://forums.developer.apple.com/thread/13580 */

extension String {
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
}