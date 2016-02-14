//
//  User.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData
import UIKit

@objc(User)

class User: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var filePath : String?
    @NSManaged var desctiption: String
    @NSManaged var fullImageURL : String?
    @NSManaged var about : String?
    @NSManaged var role: String?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /* Custom init */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        /* Get associated entity from our context */
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        
        /* Super, get to work! */
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        /* Assign our properties */
        
    }
    
    var image: UIImage? {
        get {
            guard filePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(filePath!)
        }
        set {
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: filePath!)
        }
    }
}

/* Added to help bridge the gap for finding the last path component in Swift
Reference are here: https://forums.developer.apple.com/thread/13580 */

extension String {
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
}