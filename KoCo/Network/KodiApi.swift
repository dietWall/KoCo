//
//  KodiApi.swift
//  KoCo
//
//  Created by dietWall on 24.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation
import UIKit


extension KodiPlayer {
    
    enum KodiErrors{
        case NotReachable
    }
    
    
    enum Direction : String{
        case Up = "Input.Up"
        case Down = "Input.Down"
        case Left = "Input.Left"
        case Right = "Input.Right"
        case Enter = "Input.Select"
        case Back = "Input.Back"
    }
    
    
    /**
     Description: Sends a request to server
     - parameters:
     - request: full Urlrequest to send
     - completion: will be called if request is finished
     */
    private func request(request: URLRequest, completion: @escaping (Data?, HTTPURLResponse?, Error?)-> Void){
        let defaultsession = URLSession(configuration: .default)
        defaultsession.dataTask(with: request, completionHandler: {
            data, response, error in
            completion(data, response as? HTTPURLResponse, error)
        }).resume()
    }
    
    /**
     Description: Sends a request to server
     - parameters:
     - request: full Urlrequest to send
     - completion: will be called if request is finished
     */
    private func genericRequest<ResponseType:Codable>(request: URLRequest, completion: @escaping (ResponseType?, HTTPURLResponse?, Error?)-> Void){
        
        let defaultsession = URLSession(configuration: .default)
        
        defaultsession.dataTask(with: request, completionHandler: {
            
            data, response, error in
            
            guard let response = response as! HTTPURLResponse? else{
                completion(nil, nil, error)
                return
            }
            
            
            if response.statusCode == 200{
                do {
                    
                    let result = try self.decodeJson(type: ResponseType.self, data: data!)
                    completion(result, response, error)
                    return
                }catch let decodeError{
                    //decode as RpcError
                    print("Error: \(decodeError)")
                    print(String(data: data!, encoding: .utf8)!)
                    
                    completion(nil, nil, decodeError)
                }
            }
            else{
                print("genericRequest: Statuscode: \(response.statusCode)")
                completion(nil, response, error)
            }
        }).resume()
    }
    
    /**
     Description: Decodes a Json Data response to a specific object
     Throws an error from decoder if data type is not correct
    */
    private func decodeJson<ResponseType: Codable>(type: ResponseType.Type, data: Data) throws -> ResponseType{
        let decoder = JSONDecoder()
        let result = try decoder.decode(JsonRpcResponse<ResponseType>.self, from: data)
        
        return result.result
    }
    
    //MARK: Api
    
    /**
     Description: retrieves the ApiVersion from Kodi
     Version is returned via completion
    */
    func getVersion(completion: @escaping (Version?, HTTPURLResponse?, Error? ) -> Void){
        
        let urlRequest = URLRequest.kodiRequest(url: self.url, method: "JsonRpc.GetVersion" )
        
        request(request: urlRequest){
            data, response, error in
            
            if let response = response{
                if response.statusCode == 200{
                    do {
                        let result = try self.decodeJson(type: VersionObj.self, data: data!)
                        completion(result.version, response, error)
                        return
                    }catch let decodeError{
                        //decode as RpcError
                        print("Error: \(decodeError)")
                    }
                }
            }
            
            completion(nil, response, error)
        }
    }
    
    
    /**
     Description: sends a "navigation button pressed" to Kodi
     result: "OK" if it worked
    */
    func navigate(to direction: Direction, completion: @escaping (String?, HTTPURLResponse?, Error?)->Void){
        
        let urlRequest = URLRequest.kodiRequest(url: self.url, method: direction.rawValue)
        
        request(request: urlRequest){
            data, response, error in
            
            if let response = response{
                if response.statusCode == 200{
                    do {
                        let result = try self.decodeJson(type: String.self, data: data!)
                        completion(result, response, error)
                        return
                    }catch let decodeError{
                        //decode as RpcError
                        print("Error: \(decodeError)")
                    }
                }
            }
            completion(nil, response, error)
        }
    }
    
    /**
     Description: sends a generic Button press to Kodi
     result: "Ok" if it worked
    */
    func inputExecuteAction(for action: Action, completion: @escaping (String?, HTTPURLResponse?, Error?)->Void){
        let urlRequest = URLRequest.kodiRequest(url: self.url, data: ActionParam(action: action), method: "Input.ExecuteAction")
        
        request(request: urlRequest){
            data, response, error in
            
            if let response = response{
                if response.statusCode == 200{
                    do {
                        let result = try self.decodeJson(type: String.self, data: data!)
                        completion(result, response, error)
                        return
                    }catch let decodeError{
                        
                        //decode as RpcError
                        print("Error: \(decodeError)")
                        print("String: " + String(data: data!, encoding: .utf8)!)
                    }
                }
            }
            completion(nil, response, error)
        }
    }

    /**
     Description: Retrieves current active Players
     up to 2 players could be active: Music plays and image are displayed on screen
    */
    func getPlayerStatus(completion: @escaping ([ActivePlayer]?, HTTPURLResponse?, Error? )-> Void){
        let urlRequest = URLRequest.kodiRequest(url: self.url, method: "Player.GetActivePlayers")
        
        request(request: urlRequest){
            data, response, error in
            
            if let response = response{
                if response.statusCode == 200{
                    do {
                        let result = try self.decodeJson(type: [ActivePlayer].self, data: data!)
                        //print("ActivePlayers: \(result)")
                        completion(result, response, error)
                        return
                    }catch let decodeError{
                        
                        //decode as RpcError
                        print("Error: \(decodeError)")
                        print("String: " + String(data: data!, encoding: .utf8)!)
                    }
                }
            }
            completion(nil, response, error)
        }
    }
    
    
    func getAudioItem(){
        
    }
    
    
    func getArtists(properties: ArtistsGet, completion: @escaping (ArtistObj?, HTTPURLResponse?, Error?)->Void){
        let artistRequest = URLRequest.kodiRequest(url: self.url, data: properties, method: "AudioLibrary.GetArtists")
        self.genericRequest(request: artistRequest, completion: completion)
    }

    
    func getCurrentItem(properties: [ListFiedsAll], playerId: Int, completion: @escaping (AudioItemReturn?, HTTPURLResponse?, Error?)->Void){
        let itemRequest = URLRequest.kodiRequest(url: self.url, data: CurrentItemRequest(properties: properties, playerid: playerId), method: "Player.GetItem")
        self.genericRequest(request: itemRequest, completion: completion)
    }
    
    
    func setVolume(percentage: Int, completion: @escaping (Int?, HTTPURLResponse?, Error?)->Void ){
        print("Kodiplayer: Setvolume : \(percentage)")
        let volumeParams = VolumeParams(volume: percentage)
        let volumeRequest = URLRequest.kodiRequest(url: self.url, data: volumeParams, method: "Application.SetVolume")
        self.genericRequest(request: volumeRequest, completion: completion)
    }
    
    func seekPosition(params: SeekRequest,  completion: @escaping (PlayerPosition?, HTTPURLResponse?, Error?)-> Void){
        print("Kodiplayer: SeekPosition: \(String(describing: params.value))")
        let seekRequest = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.Seek")
        self.genericRequest(request: seekRequest, completion: completion)
    }
    
    

    
    func getPlayerProperties(params: PlayerPropertiesRequest, completion: @escaping (CurrentProperties?, HTTPURLResponse?, Error?)->Void){
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.GetProperties")
        self.genericRequest(request: request, completion: completion)
    }
    
    
    
}


//MARK: KodiFileHandling API
extension KodiPlayer{
    
    func fileDownload(kodiFileUrl: String, completion: @escaping (FileDownloadResponse?, HTTPURLResponse?, Error?)->Void){
        let fileRequest = FileDownloadRequest(path: kodiFileUrl)
        let request = URLRequest.kodiRequest(url: self.url, data: fileRequest, method: "Files.PrepareDownload")
        self.genericRequest(request: request, completion: completion)
    }
    
    
    func getImage(kodiFileUrl: String) -> UIImage?{
        
        guard let url = URL(string: self.prefix + self.host + "/" +  kodiFileUrl) else{
            return nil
        }
        
        do{
            guard let img = try UIImage.fromURL(url: url) else {
                return nil
            }
            
            return img
        }
        catch let error{
            print("error \(error) with: \(url.absoluteURL)")
        }
        
        return nil
    }
}


//MARK: Player.API
extension KodiPlayer{
    
    func setShuffle(playerId: Int, shuffle: Bool, completion: @escaping (String?, HTTPURLResponse?, Error?)-> Void){
        let params = SetShuffleParams(playerid: playerId, shuffle: shuffle)
        
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.SetShuffle")
        
        self.genericRequest(request: request, completion: completion)
    }
    
    func setRepeat(playerId: Int, mode: RepeatMode, completion: @escaping (String?, HTTPURLResponse?, Error?)->Void){
        let params = SetRepeatParams(playerid: playerId, repeatMode: mode)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.SetRepeat")
        
        self.genericRequest(request: request, completion: completion)
    }
    
}
