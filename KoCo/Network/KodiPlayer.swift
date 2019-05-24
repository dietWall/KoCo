//
//  KodiPlayer.swift
//  KoCo
//
//  Created by dietWall on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

class KodiPlayer : Codable{
    
    let url : String
    
    let name : String
    
    let user : String?
    
    let password : String?
    
    init?(name: String, url: String, user: String?, password: String?)
    {
        if(KodiPlayer.checkUrl(url: url) == false){
            return nil
        }
        self.url = url
        self.name = name
        self.user = user
        self.password = password
    }
    
    
    static private func checkUrl(url: String) -> Bool{
        let urlInstance = URL(string: url)
        
        if(urlInstance != nil)
        {
            return true
        }
        return false
    }
}
