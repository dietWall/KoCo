//
//  KodiPlayer.swift
//  KoCo
//
//  Created by dietWall on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

class KodiPlayer : Codable{
    
    let host : String
    
    let url : URL
    
    let name : String
    let user : String?
    let password : String?
    
    let suffix = "/jsonrpc"
    let prefix = "http://"
    
    init?(name: String, url: String, user: String?, password: String?)
    {
        self.host = url
        self.name = name
        self.user = user
        self.password = password
        
        guard let fullUrl = URL(string: prefix + host + suffix) else{
            return nil
        }
        self.url = fullUrl
    }
    
    static var player : KodiPlayer?
}



