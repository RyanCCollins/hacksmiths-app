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
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    func maximizeView(sender: AnyObject) {
        SpringAnimation.spring(0.7, animations: {
            self.view.transform = CGAffineTransformMakeScale(1, 1)
        })
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
}

extension UIViewController {
    /**
     Helper function for utilizing an alert controller.
     
     - Parameter titles: An array of strings to set the titles of the alert controller items
     - Parameter message: A single string to show as the title for the alert controller
     - Parameter callbackHandlers: an array of functions to call on button press, matches the order of the actions.
     
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

extension UIView {
    func fadeIn(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, alpha: CGFloat = 1.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)
    }
    
    func fadeOut(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, endAlpha alpha: CGFloat = 0.2, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)
    }
    
    func transformIn(sender: AnyObject, transformationScale scale: (CGFloat, CGFloat) = (0.935, 0.935)) {
        SpringAnimation.spring(0.7, animations: {
            self.transform = CGAffineTransformMakeScale(1, 1)
        })
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    func transformOut(sender: AnyObject, transformationScale scale: (CGFloat, CGFloat) = (0.935, 0.935)) {
        SpringAnimation.spring(0.7, animations: {
            self.transform = CGAffineTransformMakeScale(scale)
        })
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
}

/* Extension for parsing a string as a date */
extension String {
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
    
    func stringByRemovingHTML() -> String {
        let noHTMLString = self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        return noHTMLString
    }
}

extension NSDate {
    func parseAsString() -> String? {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.stringFromDate(self)
        return date
    }
}

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
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
