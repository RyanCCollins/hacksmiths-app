//
//  Person.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/13/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import CoreData
import PromiseKit

/** Person managed object - Used to store people's information returned from the API
 */
@objc(Person)
class Person: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email : String?
    @NSManaged var bio: String?
    @NSManaged var isPublic: Bool
    @NSManaged var isLeader: Bool
    @NSManaged var isTopContributor: Bool
    @NSManaged var avatarURL: String?
    @NSManaged var avatarFilePath: String?
    @NSManaged var website: String?
    @NSManaged var githubUsername: String?
    @NSManaged var twitterUsername: String?
    @NSManaged var sortPriority: NSNumber?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /** Initialize the core data managed object
     *
     *  @param dictionary - a Dictionary containing the person's information
     *  @param context - the managed object context
     *  @return None
     */
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        let name = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.name] as! [String : AnyObject]
        id = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData._id] as! String
        if let lname = name["last"] as? String, fname = name["first"] as? String {
            lastName = lname
            firstName = fname
        }
        if let userEmail = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.email] as? String {
            email = userEmail
        }
        
        //* Bio comes in markdown, so remove the html and save it
        if let userBio = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.bio] as? [String : AnyObject] {
            let theBio = userBio["html"] as! String
            self.bio = theBio.stringByRemovingHTML()
        }
        
        if let photoDictionary = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.photo] as? [String : AnyObject] {
            avatarURL = photoDictionary["url"] as? String
            avatarFilePath = avatarURL?.lastPathComponent
        }
        
        if let leadershipStatus = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isLeader] as? Bool {
            isLeader = leadershipStatus
        } else {
            isLeader = false
        }
        
        // Will never be nil since default is set for these on the API
        isPublic = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.isPublic] as! Bool
        isTopContributor = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.isTopContributor] as! Bool
        sortPriority = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Meta.sortPriority] as? NSNumber
        
        if let twitterUsername = parseTwitterUsername(dictionary) {
            self.twitterUsername = twitterUsername
        }
        
        if let githubUsername = parseGithubUsername(dictionary) {
            self.githubUsername = githubUsername
        }

        if let website = dictionary[HacksmithsAPIClient.JSONResponseKeys.MemberData.Profile.website] as? String {
            self.website = website
        }
    }
    
    /** Parse the person's twitter username from the API data
     *
     *  @param jsonDict: JsonDict -  A dictionary containing the user's API data
     *  @return String? - An optional twitter username string
     */
    private func parseTwitterUsername(jsonDict: JsonDict) -> String? {
        if let services = jsonDict[HacksmithsAPIClient.JSONResponseKeys.MemberData.Services.key] as? JsonDict {
            if let twitter = services[HacksmithsAPIClient.JSONResponseKeys.MemberData.Services.twitter] as? JsonDict {
                if let twitterUsername = twitter[HacksmithsAPIClient.JSONResponseKeys.MemberData.Services.Twitter.username] as? String {
                    return twitterUsername
                }
            }
        }
        return nil
    }
    
    /** Parse the user's github user name from the API data
     *
     *  @param jsonDict: JsonDict - A dictionary containing the data from API
     *  @return String? - An optional string of the person's github username
     */
    private func parseGithubUsername(jsonDict: JsonDict) -> String? {
        if let services = jsonDict[HacksmithsAPIClient.JSONResponseKeys.MemberData.Services.key] as? JsonDict {
            if let github = services[HacksmithsAPIClient.JSONResponseKeys.MemberData.Services.github] as? JsonDict {
                if let githubUsername = github[HacksmithsAPIClient.JSONResponseKeys.MemberData.Services.Github.username] as? String {
                    return githubUsername
                }
            }
        }
        return nil
    }
    
    /** Fetch images for a person returning a Void promise saying that the image was saved
     *
     *  @param None
     *  @return Promise<Void> - A promise of a saved image
     */
    func fetchImages() -> Promise<Void> {
        return Promise{resolve, reject in
            guard avatarURL != nil else {
                resolve()
                return
            }
            HacksmithsAPIClient.sharedInstance().taskForGETImageFromURL(avatarURL!, completionHandler: {image, error in
            
                if error != nil {
                    reject(error!)
                } else {
                    self.image = image
                    resolve()
                }
            })
        }
    }
    
    /** Computed property for full name of person
     */
    var fullName: String? {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    
    /** Computed property for the person's image
     */
    var image: UIImage? {
        get {
            guard avatarFilePath != nil else {
                return nil
            }
            
            return HacksmithsAPIClient.Caches.imageCache.imageWithIdentifier(avatarFilePath!)
        }
        set {
            guard avatarFilePath != nil else {
                return
            }
            HacksmithsAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: avatarFilePath!)
        }
    }
    
    /** Computed property for the person's github url
     */
    var githubURL: NSURL? {
        get {
            guard githubUsername != nil else {
                return nil
            }
            
            let URLString = "http://github.com/" + githubUsername!
            return NSURL(string: URLString)
        }
    }
    
    /** Computed property for the person's twitter url
     */
    var twitterURL: NSURL? {
        get {
            guard twitterUsername != nil else {
                return nil
            }
            
            let URLString = "http://twitter.com/" + twitterUsername!
            return NSURL(string: URLString)
        }
    }
}
