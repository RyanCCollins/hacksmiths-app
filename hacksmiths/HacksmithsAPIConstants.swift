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
            static let BaseUrl = "http://hacksmiths.com/api/"
            static let TestURL = "http://localhost:4000/api/v1/"
            static let BaseUrlSecure = "http://hacksmiths.com/api/v1/"
        }
    
        struct Keys {

        }
        
        struct Values {

            struct Methods {
                static let SEARCH = "flickr.photos.search"
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