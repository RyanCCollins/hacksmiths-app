//
//  ProfileUpdateJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss


struct UserKeys {
    static let id = "_id"
    static let bio = "bio"
    static let email = "email"
    static let website = "website"
    static let isPublic = "isPublic"
    static let photo = "photo.url"
    static let notifications = "notifications"
    static let mobile = "mobile"
    static let mentoring = "mentoring"
    static let name = "name"
    static let availability = "availability"
    static let dateUpdated = "dateUpdated"
}
struct BioKeys {
    static let md = "md"
}

struct NameKeys {
    static let first = "first"
    static let last = "last"
}

struct AvailabilityKeys {
    static let isAvailableForEvents = "isAvailableForEvents"
    static let description = "description.md"
}


struct MentoringKeys {

    static let available = "available"
    static let needsAMentor = "needsAMentor"
    static let experience = "experience"
    static let want = "want"
}

struct NotificationKeys {
    static let mobile = "mobile"
    static let deviceToken = "deviceToken"
}

/* - Working with the rest of the data types here, the UserJSONObject takes user data
 *   and returns a User object to be posted to the API for profile update.
 * - parameters - UserData object, containing all required and any optional fields
 * - return - JSON structured exactly in the way the API is looking for it.
 */
struct UserJSONObject: Glossy {
    let user: UserProfileJSON
    
    /* Mapping from user data to JSON */
    init(userData: UserData) {
        let userData = UserProfileJSON(userData: userData)
        self.user = userData
    }
    
    /* Map from JSON to user data. */
    init?(json: JSON) {
        guard let user = UserProfileJSON(json: json) else {
            print("Unable to create user: \(json)")
            return nil
        }
        self.user = user
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "user" ~~> self.user
        ])
    }
}


/* - Encodes user's profile data as JSON for communicating with the API
 * - parameters - UserData object, containing all required and any optional fields
 * - return - JSON structured exactly in the way the API is looking for it.
 */
struct UserProfileJSON: Glossy {
    let id: String
    let name: NameJSON?
    let email: String
    let website: String?
    let isPublic: Bool
    
    let bio: BioJSON?
    let notifications: NotificationJSON?
    let availability: AvailabilityJSON?
    let mentoring: MentoringJSON?
    let photo: String?
    let dateUpdated: String?
    
    init?(json: JSON) {
        guard let name: JSON = UserKeys.name <~~ json,
              let id: String = UserKeys.id <~~ json,
              let mentoring: JSON = UserKeys.mentoring <~~ json,
              let notifications: JSON = UserKeys.notifications <~~ json,
              let availability: JSON = UserKeys.availability <~~ json,
              let email: String = UserKeys.email <~~ json else {
            return nil
        }

        self.name = NameJSON(json: name)
        self.email = email
        
        self.website = UserKeys.website <~~ json
        
        if let isPublic: Bool = UserKeys.isPublic <~~ json {
            self.isPublic = isPublic
        } else {
            self.isPublic = false
        }
        
        if let bio: JSON = UserKeys.bio <~~ json {
            self.bio = BioJSON(json: bio)
        } else {
            self.bio = nil
        }
        
        self.notifications = NotificationJSON(json: notifications)
        self.availability = AvailabilityJSON(json: availability)
        self.mentoring = MentoringJSON(json: mentoring)
        
        self.photo = UserKeys.photo <~~ json
        
        self.dateUpdated = UserKeys.dateUpdated <~~ json
        self.id = id
    }
    
    init(userData: UserData) {
        self.name = NameJSON(userData: userData)
        self.bio = BioJSON(userData: userData)
        
        self.email = userData.email
    
        if let website = userData.website {
            self.website = website
        } else {
            self.website = nil
        }
        
        self.isPublic = userData.isPublic
        self.notifications = NotificationJSON(userData: userData)
        self.availability = AvailabilityJSON(userData: userData)
        self.mentoring = MentoringJSON(userData: userData)
        self.photo = userData.avatarURL
        self.dateUpdated = userData.dateUpdated.parseAsString()
        self.id = userData.idString
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "bio" ~~> self.bio,
            "website" ~~> self.website,
            "isPublic" ~~> self.isPublic,
            "notifications" ~~> self.notifications,
            "availability" ~~> self.availability,
            "notifications" ~~> self.notifications,
            "mentoring" ~~> self.mentoring,
        ])
    }
}

/* - NameJSON object, represents the complexity of how the data is stored on the API
 * - parameters - JSON or UserData to provide two way serialization.
 * - return - JSON data structured for API calls.
 */
struct NameJSON: Glossy {
    var firstname: String
    var lastname: String
    
    init?(json: JSON) {
        guard let first: String = NameKeys.first <~~ json,
            let last: String = NameKeys.last <~~ json else {
                return nil
        }
        self.firstname = first
        self.lastname = last
    }
    
    init(userData: UserData) {
        let name = userData.name
        let nameArray = name.componentsSeparatedByString(" ")
        if nameArray.count >= 2 {
            self.firstname = nameArray[0]
            self.lastname = nameArray[1]
        } else {
            self.firstname = name
            self.lastname = ""
        }
    }
    
    var fullname: String? {
        get {
            return "\(firstname) \(lastname)"
        }
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "first" ~~> self.firstname,
            "last" ~~> self.lastname
        ])
    }
}

/* Availability JSON creates a JSON object that the API will understand for posting profile updates
 * @param - UserData object, containing all required and any optional fields for availability
 * @return - JSON structured exactly in the way the API is looking for it.
 */
struct AvailabilityJSON: Glossy {
    let isAvailableForEvents: Bool
    let descriptionString: String?
    
    init?(json: JSON) {
        if let isAvailable: Bool = AvailabilityKeys.isAvailableForEvents <~~ json {
            self.isAvailableForEvents = isAvailable
        } else {
            isAvailableForEvents = false
        }
        
        if let descriptionString: String = AvailabilityKeys.description <~~ json {
            self.descriptionString = descriptionString
        } else {
            self.descriptionString = ""
        }
    }
    
    /** Initialize the availabi
     *
     *  @param
     *  @return
     */
    init(userData: UserData) {
        self.isAvailableForEvents = userData.isAvailableForEvents
        if let availabilityDescription = userData.availabilityExplanation {
            self.descriptionString = availabilityDescription
        } else {
            self.descriptionString = nil
        }
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            AvailabilityKeys.isAvailableForEvents ~~> self.isAvailableForEvents,
            AvailabilityKeys.description ~~> self.descriptionString
        ])
    }
}


/* - Encodes user's profile data as JSON for communicating with the API
 * - parameters - UserData object, containing all required and any optional fields
 * - return - JSON structured exactly in the way the API is looking for it.
 */
struct MentoringJSON: Glossy {
    let available: Bool
    let needsAMentor: Bool
    let experience: String?
    let want: String?
    
    init?(json: JSON) {
        self.available = (MentoringKeys.available <~~ json)!
        self.needsAMentor = (MentoringKeys.needsAMentor <~~ json)!
        
        self.experience = MentoringKeys.experience <~~ json
        self.want = MentoringKeys.want <~~ json
    }
    
    init(userData: UserData) {
        self.available = userData.isAvailableAsAMentor
        self.needsAMentor = userData.needsAMentor
        if let experience = userData.hasExperience {
            self.experience = experience
        } else {
            self.experience = ""
        }
        
        if let wantsExperience = userData.wantsExperience {
            self.want = wantsExperience
        } else {
            self.want = ""
        }
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "available" ~~> self.available,
            "needsAMentor" ~~> self.needsAMentor,
            "experience" ~~> self.experience,
            "want" ~~> self.want
        ])
    }
}

/* - Encodes notifications to JSON for posting to API
 * - parameters - mobile, Bool telling if the user's mobile notifications are on or off.
 * - return - JSON structured exactly in the way the API is looking for it for Notifications
 */

struct NotificationJSON: Glossy {
    var mobile: Bool
    var deviceToken: String?
    
    init?(json: JSON) {
        guard let mobileNotifications: Bool = NotificationKeys.mobile <~~ json else {
            return nil
        }
        self.mobile = mobileNotifications
        if let deviceToken = UserService.sharedInstance().deviceToken {
            self.deviceToken = deviceToken
        } else if let deviceToken: String? = NotificationKeys.deviceToken <~~ json {
            self.deviceToken = deviceToken
        }
    }
    
    init(userData: UserData) {
        self.mobile = userData.mobileNotifications
        
        /* Set the device token from the user Service if possible*/
        if let deviceToken = UserService.sharedInstance().deviceToken {
            self.deviceToken = deviceToken
        } else if let deviceToken = userData.deviceToken {
            self.deviceToken = deviceToken
        }
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "mobile" ~~> self.mobile,
            "deviceToken" ~~> self.deviceToken
        ])
    }
}


/* - Encodes the user's bio to JSON to post to API
 * - parameters - Bio string in md format
 * - return - JSON structured exactly in the way the API is looking for it for bio.
 */
struct BioJSON: Glossy {
    
    let md: String?
    
    /* Allow initialization with userData, making bridging between core data and API seemless */
    init(userData: UserData) {
        self.md = userData.bio ?? ""
    }
    
    init?(json: JSON) {
        guard let mdBio: String = BioKeys.md <~~ json else {
            self.md = ""
            return
        }
        self.md = mdBio
    }
    func toJSON() -> JSON? {
        return jsonify([
            "md" ~~> self.md
        ])
    }
}