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
            static let URL = "http://hacksmiths.io"
            static let BaseUrl = "http://hacksmiths.io/api/"
            static let TestURL = "http://localhost:4000/api/"
            static let BaseUrlSecure = "http://hacksmiths.com/api/v1/"
        }
    
    struct Routes {
        static let Stats = "stats"
        static let App = "app"
        static let Status = "status"
        static let rsvp = "rsvp"
        static let SigninEmail = "signin-email"
        static let SignupEmail = "signup-email"
        static let SigninService = "signin-service"
        static let SigninServiceCheck = "signin-service-check"
        static let SigninRecover = "signin-recover"
        
    }
    
        struct Keys {
            
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