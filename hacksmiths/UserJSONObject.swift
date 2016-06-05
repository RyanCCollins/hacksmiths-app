//
//  ProfileUpdateJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

/*  Working with the rest of the data structures here, the UserJSONObject takes user data
 *  and returns a User object to be posted to the API for profile update. It takes care of
 *  Serializing and deserializing back and forth from Core Data to the API.
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


/** Encode the user data object for profile, serializing and deserializing
 *  from JSON to core data model
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
    
    /** Initialize the JSON object from json returned from API
     *
     *  @param json - the JSON object to deserialize
     *  @return None
     */
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
    
    /** Serialize the data from the UserData object to json to be submit to API
     *
     *  @param userData - the User core data model object
     *  @return None
     */
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

/** Serialize / Deserialize the Name object for a user
 */
struct NameJSON: Glossy {
    var firstname: String
    var lastname: String
    
    /** Initialize the name object from json
     *
     *  @param json - the JSON data returned from the API
     *  @return None
     */
    init?(json: JSON) {
        guard let first: String = NameKeys.first <~~ json,
            let last: String = NameKeys.last <~~ json else {
                return nil
        }
        self.firstname = first
        self.lastname = last
    }
    
    /** Serialize the User Data as JSON for the name object
     *
     *  @param userData - the UserData to serialize
     *  @return None
     */
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


/** Serialize and deserialize the user's availability data from API to Core Data model
 */
struct AvailabilityJSON: Glossy {
    let isAvailableForEvents: Bool
    let descriptionString: String?
    
    /** Initialize the JSON object from json returned from the API
     *
     *  @param json - the json data returned from the API
     *  @return None
     */
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
    
    /** Initialize the availability model for user
     *
     *  @param userData - the userData to serialize
     *  @return None
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
/** Serialize the user's profile data as JSON for communication with API.
 *  Deserialize from JSON to core data model
 */
struct MentoringJSON: Glossy {
    let available: Bool
    let needsAMentor: Bool
    let experience: String?
    let want: String?
    
    /** Desiarilize json from API
     *
     *  @param json - the JSON object for mentoring data from the API
     *  @return None
     */
    init?(json: JSON) {
        self.available = (MentoringKeys.available <~~ json)!
        self.needsAMentor = (MentoringKeys.needsAMentor <~~ json)!
        
        self.experience = MentoringKeys.experience <~~ json
        self.want = MentoringKeys.want <~~ json
    }
    
    /** Serialize user data as JSON to communicate with the API
     *
     *  @param userData - the user Data to serialize
     *  @return None
     */
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

/** Serialize and deserialize the notifications to JSON for posting to the API
 */
struct NotificationJSON: Glossy {
    var mobile: Bool
    var deviceToken: String?
    
    /** Initialize the JSON object
     *
     *  @param json - the JSON from the API
     *  @return None
     */
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
    
    /** Initialize JSON from User Data
     *
     *  @param userData - the UserData to encode as JSON
     *  @return None
     */
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



/** Encodes the user's bio to JSON to post to API
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

/** Keys that are used in the User JSON Object on the API. 
 *  Maps nicely to the data stored in the UserJSONObject
 */
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