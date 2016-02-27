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
            static let BaseURL = "http://localhost:4000/"
            static let APIURL = "http://localhost:4000/api/app/"
            static let App = "app/"
            
        }
    
    struct Secrets {
        static let Session = "vxEH19I80ZgnieRQXYeue6KHYqmj3L2l"
        static let Token = "asdfj88jfejajJJJEeer3399KDKNnnjdAKwoeiDj"
    }
    
    struct Routes {
        static let Stats = "stats/"
        
        static let EventStatus = "event-status/"
        static let RSVP = "rsvp/"
        static let SigninEmail = "signin-email/"
        static let SignupEmail = "signup-email"
        static let SigninService = "signin-service/"
        static let SigninServiceCheck = "signin-service-check/"
        static let SigninRecover = "signin-recover/"
        static let Members = "members/"
        
    }
    
        struct Keys {
            static let Username = "username"
            static let Body = "body"
            static let Password = "password"
        }
        
        struct Values {
            
            struct Methods {
                
            }
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
            
            
            struct Permissions {
                static let isAdmin = "isAdmin"
                static let isTeamLeader = "isTeamLeader"
                static let isMember = "isMember"
            }
            
            struct Memberships {
                static let enrollments = "enrollments"
                static let enrollmentStatus = "enrollmentStatus"
                static let teams = "teams"
                static let organization = "organization"
            }
            
            
            struct Profile {
                static let isPublic = "isPublic"
                static let isLeader = "isLeader"
                static let photo = "photo"
                static let website = "website"
                static let gravatar = "gravatar"
                static let bio = "bio"
                
                // This is the URL for their photo
                static let avatarUrl = "avatarUrl"
            }
            
            struct EventInvolvement {
                struct availability {
                    static let daysAvailable = "daysAvailable"
                    static let isAvailableForEvents = "isAvailableForEvents"
                    static let explanation = "explanation"
                }

                
                static let areasOfExpertise = "areasOfExpertise"
                static let skillExplanation = "skillExplanation"
                static let rolesToFill = "rolesToFill"
                static let projectInterests = "projectInterests"
            }
            
            struct Services {
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
            
            struct Notifications {
                static let notifications = "notifications"
                static let posts = "posts"
                static let projects = "projects"
                static let events = "events"
            }
            
            struct Settings {
                static let settings = "settings"
            }
            
            struct Meta {
                static let isTopContributor = "isTopContributor"
                static let sortPriority = "sortPriority"
                static let rank = "rank"
                static let lastRSVP = "lastRSVP"
                static let projectsContributedTo = "projectsContributedTo"
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
            static let startDate = "startDate"
            static let endDate = "endDate"
            static let place = "place"
            static let map = "map"
            static let maxRSVPs = "maxRSVPs"
            static let totalRSVPs = "totalRSVPs"
            static let spotsAvailable = "spotsAvailable"
            static let spotsRemaining = "spotsRemaining"
            static let state = "state"
            static let publishedDate = "publishedDate"
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
            static let name = "name"
            static let logo = "logo"
            static let logoUrl = "logoUrl"
            static let isHiring = "isHiring"
            static let description = "description"
            static let location = "location"
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