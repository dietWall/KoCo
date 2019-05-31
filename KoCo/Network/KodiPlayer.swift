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
