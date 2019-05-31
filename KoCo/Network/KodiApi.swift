//
//  KodiApi.swift
//  KoCo
//
//  Created by dietWall on 24.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation




struct VersionObj : Codable {
    var version : Version
}

struct Version : Codable{
    var major : Int
    var minor : Int
    var patch : Int
}




extension KodiPlayer {
    
    enum KodiErrors{
        case NotReachable
    }
    
    var suffix : String{
        get{
            return  "/jsonrpc"
        }
    }
    
    var prefix : String{
        get{
            return   "http://"
        }
    }
    
    enum Direction : String{
        case Up = "Input.Up"
        case Down = "Input.Down"
        case Left = "Input.Left"
        case Right = "Input.Right"
        case Enter = "Input.Select"
        case Back = "Input.Back"
    }
    
    
    var request : URLRequest?{
        get{
            if let url = URL(string: self.prefix + self.url + self.suffix){
                var request = URLRequest(url: url)
                
                //configure Request
                request.httpMethod = "POST"
                request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = TimeInterval(5.0)     //60 s is far too long
                return request
            }
            return nil
        }
    }
    
    var server : JsonRpcCommunication{
        get{
            return JsonRpcCommunication(request: self.request!)
        }
    }
    
    
    
    func getVersion(completion: @escaping (Version?, HTTPURLResponse?, Error? ) -> Void){
        
        self.server.jsonRpcRequest(responseType: JsonRpcResponse<VersionObj>.self, method: "JSONRPC.Version", completion: { (version, response, error) in
            if error == nil{
                if version != nil{
                    completion(version?.result.version, response, error)
                    return
                }
            }
            completion(nil, response, error)
        })
    }
    
    func navigate(to direction: Direction){
        self.server.jsonRpcRequest(responseType: JsonRpcResponse<String>.self, method: direction.rawValue, completion: {_,_,_ in })
    }


    
}
