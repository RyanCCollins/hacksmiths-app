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
        
        static let Status = "status/"
        static let rsvp = "rsvp/"
        static let SigninEmail = "signin-email/"
        static let SignupEmail = "signup-email"
        static let SigninService = "signin-service/"
        static let SigninServiceCheck = "signin-service-check/"
        static let SigninRecover = "signin-recover/"
        
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
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Photo = "photo"
        static let Photos = "photos"
        static let Pages = "pages"
        static let Page =  "page"
        static let ID = "id"
        static let Title = "title"
        
        struct StatusMessage {
            static let OK = "ok"
            static let Fail = "fail"
        }
        struct ImageSizes {
            static let MediumURL = "url_m"
            static let ThumbnailURL = "url_t"
            static let LargeURL = "url_b"
        }
        
    }
    
    enum HTTPRequest {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
}