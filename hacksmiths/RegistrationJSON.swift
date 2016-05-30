//
//  RegistrationJSON.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/30/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import Gloss

/* Handle encoding the registration data to JSON
 * For submission to the API.
 * All fields are required and calling the
 * Encodable toJSON method will encode the data to a JSON object for registration
 */
struct RegistrationJSON: Encodable {
    var fullname: String
    var email: String
    var password: String
    
    /* Encodes the model to JSON
     * @return - JSON? - a JSON object representing the data needed by API.
     */
    func toJSON() -> JSON? {
        return jsonify([
           "fullname" ~~> fullname,
            "email" ~~> email,
            "password" ~~> password
        ])
    }
}
