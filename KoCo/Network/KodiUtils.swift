//
//  UrlRequest.swift
//  KoCo
//
//  Created by admin on 05.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation
import UIKit


extension Array where Element: KodiPlayer{
    
    private var filename : String{
        get{
            return "players.json"
        }
    }
    
    private var url : URL{
        get{
            do{
                var tmpurl = try FileManager.default.url(
                    for: FileManager.SearchPathDirectory.applicationDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true)
                
                tmpurl.appendPathComponent(self.filename)
                
                return tmpurl
            }
            catch let error{
                print("Filemanager hat geschmissen: \(error)")
            }
            return URL(string:"Not Implemented")!
        }
    }
    
    mutating func loadData(){
        do{
            if let data = try? Data(contentsOf: self.url){
                let decoder = JSONDecoder()
                
                let result = try decoder.decode([KodiPlayer].self, from: data)
                print("Loaded: Elements count: \(result.count)")
                
                self = result as! Array<Element>
            }
        }
        catch let error{
            print("Error: \(error) at creating Playerdata from url: \(self.url) ")
        }
    }
    
    func save(){
        do{
            let coder = JSONEncoder()
            let data = try coder.encode(self)
            try data.write(to: self.url)
            let str = String(data: data, encoding: .utf8)
            print("Saving Players: " + str!)
        }
        catch let error{
            print("Error \(error), while trying to save players")
        }
    }
    
}

extension URLRequest{
    
    static func kodiRequest(url: URL, data: Data)-> URLRequest{
        var request = URLRequest(url: url)
        //configure Request
        request.httpMethod = "POST"
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TimeInterval(5.0)     //60 s is far too long
        request.httpBody = data
        request.setValue("\(data)", forHTTPHeaderField: "Content-Length")
        return request
    }
    
    static var lastRequestId : Int = 0
    
    static var nextRequestId : Int{
        get{
            URLRequest.lastRequestId += 1
            return URLRequest.lastRequestId
        }
    }
    
    
    static func kodiRequest<ParamType: Codable>(url: URL, data: ParamType, method: String)-> URLRequest{
        let requestData = JsonRpcRequest<ParamType>(id: nextRequestId, method: method, params: data)
        return self.kodiRequest(url: url, data: requestData.encode())
    }
    
    static func kodiRequest(url: URL, method: String)->URLRequest{
        let requestData = JsonRpcRequest<Int>(id: nextRequestId, method: method)
        return self.kodiRequest(url: url, data: requestData.encode())
    }
    
}

extension UIImage{
    
    static func fromURL(url: URL)throws ->UIImage?{
        let imgData = try Data(contentsOf: url)
        let img = UIImage(data: imgData)
        return img
    }

}
