//
//  KodiApi.swift
//  KoCo
//
//  Created by dietWall on 24.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


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
    


    
}




