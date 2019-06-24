//
//  KodiPlayer.swift
//  KoCo
//
//  Created by dietWall on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation
import UIKit



class KodiPlayer : Codable{
    
    enum KodiErrors: Error{
        case URLNotCorrect
    }

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
        
        if url == ""{
            return nil
        }
        
        guard let fullUrl = URL(string: prefix + host + suffix) else{
            return nil
        }
        
        self.url = fullUrl
    }
    
    static var player : KodiPlayer?{
        didSet{
            //Avoid memory cycles, delete Reference to oldValue:
            if(oldValue?.timer != nil){
                oldValue?.timer?.invalidate()
                print("Singleton: invalidating Timer")
            }
            
            player?.refreshStatus()
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case host
        case name
        case user
        case password
    }
    

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try values.decode(String?.self, forKey: .user)
        host = try values.decode(String.self, forKey: .host)
        name = try values.decode(String.self, forKey: .name)
        password = try values.decode(String.self, forKey: .password)
        
        guard let fullUrl = URL(string: prefix + host + suffix) else{
            throw KodiErrors.URLNotCorrect
        }
        self.url = fullUrl
    }
    
    
    var activePlayer : [ActivePlayer]?{
        didSet{
            NotificationCenter.default.post(name: .playerRefresh, object: nil)
        }
        
    }
    
    var activeAudioPlayer : ActivePlayer?{
        get{
            return activePlayer?.getFirstAudioPlayer()
        }
    }
    
    
    var currentProperties : CurrentProperties?{
        didSet{
            //Send Message
            NotificationCenter.default.post(name: .propertiesRefresh, object: nil)
        }
    }
    
    var imagePaths = [Library_Id : String]()
    
    var playlist : [AudioItem]?{
        didSet{
            
            if playlist != nil{
                for item in playlist!{
                    
                    //non existing  thumbnails will be == ""
                    if let thumbnail = item.thumbnail, thumbnail != ""{
                        fileDownload(kodiFileUrl: thumbnail, completion: {
                            result, response, error in
                            if let result = result{
                                //just save the path for later usage
                                self.imagePaths[item.id!] = result.details.path
                            }
                        })
                    }
                }
            }
            //Send Message
            let playlistNotification = Notification(name: .playlistRefresh, object: playlist, userInfo: nil)
            NotificationCenter.default.post(playlistNotification)
        }
    }
    
    var timer : Timer?{
        didSet{
            print("Timer set")
        }
    }

    
    var currentItem : AudioItem?{
        didSet{
            let itemNotification = Notification(name: .itemChanged, object: currentItem, userInfo: nil)
            NotificationCenter.default.post(itemNotification)
        }
    }

    
    @objc func refreshStatus(){
        
        print("setting up timer")
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(refreshStatus)), userInfo: nil, repeats: false)
        //Refresh active Players
        refreshPlayerStatus()
        refreshProperties()
        refreshPlayList()
        refreshItem()
        
        print("Kodiplayer \(self.name): RefreshStatus done")
        let statusNotification = Notification(name: .statusRefreshedNotificaten, object: nil, userInfo: nil)
        NotificationCenter.default.post(statusNotification)
    }
    
    private func refreshItem(){
        let semaphore = DispatchSemaphore.init(value: 0)
        if let playerId = activeAudioPlayer?.playerid{
            var item : AudioItem? = nil
            let properties : [ListFieldsAll] = [.title, .artist, .genre, .fanart, .thumbnail, .artistid, .album, .albumid, .setid]
            
            self.getCurrentItem(properties: properties, playerId: playerId, completion: {
                result, response, error in
                guard let result = result else {
                    return
                }
                item = result.item
                semaphore.signal()
                
            })
            semaphore.wait()
            self.currentItem = item
        }
    }
    
    private func refreshPlayerStatus(){
        //get current Active Players
        let semaphore = DispatchSemaphore.init(value: 0)
        var statusResult : [ActivePlayer]? = nil
        self.getPlayerStatus(completion: {
            result, response, error in
            
            guard let result = result else{
                semaphore.signal()
                return
            }
            statusResult = result
            semaphore.signal()
            })
        semaphore.wait()
        self.activePlayer = statusResult
    }
    
    private func refreshProperties(){
        guard let id = activeAudioPlayer?.playerid else {
            return
        }
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        let properties : [PlayerProperties] = [.playlistid, .position, .canshuffle, .percentage, .time, .totaltime, .repeated, .shuffled]
        let request = PlayerPropertiesRequest(playerid: id, properties: properties)
        
        var propertiesResult : CurrentProperties? = nil
        
        KodiPlayer.player?.getPlayerProperties(params: request, completion: {
            result, response, error in
                
            guard let result = result else{
                semaphore.signal()
                return
            }
            //self.isConnected = true
            propertiesResult = result
            semaphore.signal()
        })
        semaphore.wait()
        self.currentProperties = propertiesResult
    }
    
    
    private func refreshPlayList(){
        guard let playlistid = self.currentProperties?.playlistid else{
            return
        }
    
        let semaphore = DispatchSemaphore.init(value: 0)
        var listResult : [AudioItem]? = nil
        
        let limits = ListLimits(start: 0, end: 0, total: nil)
        let properties : [ListFieldsAll] = [.title, .artist, .genre, .fanart, .thumbnail, .artistid, .album, .albumid, .setid]
        let sort = ListSort(order: Order(rawValue: "ascending")!, method: "none", ignorearticle : true )
        
        let params = PlaylistGetItemsParams(playlistid: playlistid, properties: properties, limits: limits, sort: sort )
        
        KodiPlayer.player?.playlistGetItems(params: params, completion: {
            result, response, error in
            
            guard let result = result else{
                semaphore.signal()
                return
            }
            
            listResult = result.items
            semaphore.signal()
            //self.playlist = result.items
        })
        semaphore.wait()
        self.playlist = listResult
    }
    
}
