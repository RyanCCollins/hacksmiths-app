//
//  HacksmithsAPIConstants.swift
//  hacksmiths
//
//  Created by Ryan Collins on 2/7/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Foundation


extension HacksmithsAPIClient {
    
        struct Constants {
            static let BaseURL = "https://hacksmiths.io/"
            static let APIURL = "\(BaseURL)api/"
            static let App = "app/"
            static let Me = "me/"
            // Right now, this will direct to the plain `ol baseurl/homepage,
            // But we can alter it in order to go to an about us page
            static let InfoPage = BaseURL
        }
    
    struct Secrets {
        static let Session = "vxEH19I80ZgnieRQXYeue6KHYqmj3L2l"
        static let Token = "asdfj88jfejajJJJEeer3399KDKNnnjdAKwoeiDj"
    }
    
    struct Routes {
        static let Stats = "stats/"
        
        static let EventStatus = Constants.App +  "event-status/"
        static let RSVP = Constants.App + "rsvp/"
        static let SigninEmail = Constants.App + "signin-email/"
        static let SignupEmail = Constants.App + "signup-email"
        static let SigninService = Constants.App + "signin-service/"
        static let SigninServiceCheck = Constants.App + "signin-service-check/"
        static let SigninRecover = Constants.App + "signin-recover/"
        static let Members = Constants.App + "members/"
        static let Profile = Constants.Me + "profile/"
        static let UpdateProfile = Profile + "/update"
        static let EventAttendees = "event/"
        
    }
    
    
    
        struct Keys {
            static let Username = "username"
            static let Body = "body"
            static let Password = "password"
            static let Email = "email"
            static let FirstName = "firstName"
            static let LastName = "lastName"
            static let authUser = "authUser"
            static let user = "user"
        }
    
    struct JSONResponseKeys {
        static let Status = "status"
        static let Success = "success"
        static let Code = "code"
        static let Members = "members"
        
        struct Auth {
            static let success = "success"
            static let session = "session"
            static let date = "date"
            static let userId = "userId"
            static let message = "message"
        }
        
        struct MemberData {
            
            static let _id = "_id"
            static let key = "key"
            static let name = "name"
            static let email = "email"
            static let updatedAt = "updatedAt"
            static let createdAt = "createdAt"
            
            struct Profile {
                static let dictKey = "profile"
                static let isPublic = "isPublic"
                static let isLeader = "isLeader"
                static let photo = "photo"
                static let website = "website"
                static let gravatar = "gravatar"
                static let bio = "bio"
                static let bioMD = "md"
                
                static let first = "first"
                static let last = "last"
                
                static let totalHatTips = "totalHatTips"
                
                
                // This is the URL for their photo
                static let avatarUrl = "avatarUrl"
            }
            
            
            struct Notifications {
                static let notifications = "notifications"
                static let posts = "posts"
                static let mobile = "mobile"
                static let events = "events"
            }
            
            struct EventInvolvement {
                static let dictKey = "availability"
                
                struct availability {
                    static let daysAvailable = "daysAvailable"
                    
                    struct days {
                        static let monday = "monday"
                        static let tuesday = "tuesday"
                        static let friday = "friday"
                        static let wednesday = "wednesday"
                        static let thursday = "thursday"
                        static let saturday = "saturday"
                        static let sunday = "sunday"
                    }
                    
                    static let isAvailableForEvents = "isAvailableForEvents"
                    static let explanation = "explanation"
                }

                
                static let areasOfExpertise = "areasOfExpertise"
                static let skillExplanation = "skillExplanation"
                static let rolesToFill = "rolesToFill"
                static let projectInterests = "projectInterests"
            }
            
            struct Memberships {
                static let enrollments = "enrollments"
                static let enrollmentStatus = "enrollmentStatus"
                static let teams = "teams"
                static let organization = "organization"
            }
            
            struct Permissions {
                static let isAdmin = "isAdmin"
                static let isTeamLeader = "isTeamLeader"
                static let isMember = "isMember"
            }
            
            struct Services {
                static let key = "services"
                static let github = "github"
                static let twitter = "twitter"
                
                // These are the actual usernames for github and twitter
                static let twitterUsername = "twitterUsername"
                static let githubUsername = "githubUsername"
                
                struct Twitter {
                    static let isConfigured = "isConfigured"
                    static let profiledId = "profiledId"
                    static let username = "username"
                    static let avatar = "avatar"
                    static let refreshToken = "refreshToken"
                    static let accessToken = "accessToken"
                }
                
                struct Github {
                    static let isConfigured = "isConfigured"
                    static let profiledId = "profiledId"
                    static let username = "username"
                    static let avatar = "avatar"
                    static let refreshToken = "refreshToken"
                    static let accessToken = "accessToken"
                }
            }
            
            struct mentoring {
                static let dictionaryKey = "mentoring"
                
                static let available = "available"
                static let needsAMentor = "needsAMentor"
                static let experience = "experience"
                static let want = "want"
                static let wantsExperience = "wantsExperience"
            }
            
            struct Settings {
                static let settings = "settings"
            }
            
            struct Meta {
                static let isTopContributor = "isTopContributor"
                static let sortPriority = "sortPriority"
                static let rank = "rank"
                static let lastRSVP = "lastRSVP"
                static let projects = "projects"
            }
            
        }
        
        struct RSVP {
            static let event = "event"
            
            static let who = "who"
            static let attending = "attending"
            static let createdAt = "createdAt"
            static let changedAt = "changedAt"
        }

        struct Event {
            static let event = "event"
            static let active = "active"
            static let attendees = "attendees"
            
            static let _id = "_id"
            static let id = "id"
            static let title = "title"
            static let organization = "organization"
            static let project = "project"
            static let description = "description"
            static let marketingInfo = "marketingInfo"
            static let sponsors = "sponsors"
            static let teams = "teams"
            static let registrationStartDate = "registrationStartDate"
            static let registrationEndDate = "registrationEndDate"
            static let starts = "starts"
            static let ends = "ends"
            static let place = "place"
            static let map = "map"
            static let maxRSVPs = "maxRSVPs"
            static let totalRSVPs = "totalRSVPs"
            
            /* The spots available returns Bool, where remaining returns a number*/
            static let spotsAvailable = "spotsAvailable"
            static let spotsRemaining = "spotsRemaining"
            static let state = "state"
            static let publishedDate = "publishedDate"
            
            static let featureImage = "featureImage"
        }
        
        struct EventRSVP {
            static let eventId = "eventId"
            static let personId = "personId"
            static let updatedAt = "updatedAt"
        }
        
        struct Project {
            static let _id = "_id"
            static let key = "key"
            static let title = "title"
            static let logo = "logo"
            static let logoUrl = "logoUrl"
            static let organization = "organization"
            static let description = "description"
            static let teams = "teams"
            static let contributors = "contributors"
            static let rolesNeeded = "rolesNeeded"
            static let spotlight = "spotlight"
            static let events = "events"
            
            struct Info {
                static let url = "url"
                static let repoUrl = "repoUrl"
                static let stats = "stats"
            }
            
        }
        
        struct Organization {
            static let dictKey = "organization"
            static let id = "id"
            static let _id = "_id"
            static let name = "name"
            static let logo = "logo"
            static let logoUrl = "logoUrl"
            static let isHiring = "isHiring"
            static let description = "description"
            static let website = "website"
            static let md = "md"
            static let about = "about"
            static let url = "url"
        }
        
        struct StatusMessage {
            static let OK = "ok"
            static let Fail = "fail"
        }
        
        struct Team {
            static let _id = "_id"
            static let key = "key"
            static let title = "title"
            static let avatar = "avatar"
            static let avatarUrl = "avatarUrl"
            static let website = "website"
            static let description = "description"
            static let leaders = "leaders"
            static let location = "location"
            static let spotlight = "spotlight"
            static let roles = "roles"
            static let members = "members"
            static let projects = "projects"
        }
        
        struct Schedule {
            static let event = "event"
            static let items = "items"
            static let team = "team"
            static let who = "who"
        }

    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}