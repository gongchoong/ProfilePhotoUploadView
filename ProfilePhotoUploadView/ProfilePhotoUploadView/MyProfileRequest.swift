//
//  MyProfileRequest.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/27/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin

struct MyProfileRequest: GraphRequestProtocol {
    struct Response: GraphResponseProtocol {
        
        var name: String?
        var id: String?
        var gender: String?
        var email: String?
        
        init(rawResponse: Any?) {
            // Decode JSON from rawResponse into other properties here.
            guard let response = rawResponse as? Dictionary<String, Any> else {
                return
            }
            
            if let name = response["name"] as? String {
                self.name = name
            }
            
            if let id = response["id"] as? String {
                self.id = id
            }
            
            if let gender = response["gender"] as? String {
                self.gender = gender
            }
            
            if let email = response["email"] as? String {
                self.email = email
            }
        }
    }
    
    var graphPath = "/me"
    var parameters: [String : Any]? = ["fields": "id, name, email, gender"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}
