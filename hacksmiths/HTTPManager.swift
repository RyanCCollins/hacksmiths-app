//
//  HTTPManager.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/22/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Alamofire
import Foundation
import Timberjack

/* Enable HTTP logging in the http manager */
class HTTPManager: Alamofire.Manager {
    static let sharedManager: HTTPManager = {
        let configuration = Timberjack.defaultSessionConfiguration()
        let manager = HTTPManager(configuration: configuration)
        return manager
    }()
}
