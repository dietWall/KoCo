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
    */
    func getVersion(completion: @escaping (Version?, HTTPURLResponse?, Error? ) -> Void){
        let urlRequest = URLRequest.kodiRequest(url: self.url, method: "JsonRpc.GetVersion" )
        genericRequest(request: urlRequest, completion: completion)
    }

}

//Mark: Input API
extension KodiPlayer{
    
    enum Direction : String{
        case Up     = "Input.Up"
        case Down   = "Input.Down"
        case Left   = "Input.Left"
        case Right  = "Input.Right"
        case Enter  = "Input.Select"
        case Back   = "Input.Back"
    }
    
    /**
     Description: sends a "navigation button pressed" to Kodi
     result: "OK" if it worked
     */
    func navigate(to direction: Direction, completion: @escaping (String?, HTTPURLResponse?, Error?)->Void){
        let urlRequest = URLRequest.kodiRequest(url: self.url, method: direction.rawValue)
        genericRequest(request: urlRequest, completion: completion)
    }
    
    /**
     Description: sends a generic Button press to Kodi
     result: "Ok" if it worked
     */
    func inputExecuteAction(for action: InputAction, completion: @escaping (String?, HTTPURLResponse?, Error?)->Void){
        let urlRequest = URLRequest.kodiRequest(url: self.url, data: InputActionParam(action: action), method: "Input.ExecuteAction")
        genericRequest(request: urlRequest, completion: completion)
    }
}

//MARK: KodiFileHandling API
extension KodiPlayer{
    
    //Description: Returns a path for a file
    //
    func fileDownload(kodiFileUrl: String, completion: @escaping (FileDownloadResponse?, HTTPURLResponse?, Error?)->Void){
        let fileRequest = FileDownloadParams(path: kodiFileUrl)
        let request = URLRequest.kodiRequest(url: self.url, data: fileRequest, method: "Files.PrepareDownload")
        self.genericRequest(request: request, completion: completion)
    }
    
    //Description: Downloads a Image from Kodi
    //fileDownload must be called before downloading a file, otherwise Kodi and this function returns nil
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
    
    func setVolume(percentage: Int, completion: @escaping (Int?, HTTPURLResponse?, Error?)->Void ){
        let volumeParams = VolumeParams(volume: percentage)
        let volumeRequest = URLRequest.kodiRequest(url: self.url, data: volumeParams, method: "Application.SetVolume")
        genericRequest(request: volumeRequest, completion: completion)
    }
    
    func seekPosition(params: SeekRequest,  completion: @escaping (PlayerPosition?, HTTPURLResponse?, Error?)-> Void){
        let seekRequest = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.Seek")
        genericRequest(request: seekRequest, completion: completion)
    }
    
    func playerGetItem(properties: [ListFieldsAll], playerId: Int, completion: @escaping (AudioItemReturn?, HTTPURLResponse?, Error?)->Void){
        let itemRequest = URLRequest.kodiRequest(url: self.url, data: GetCurrentItemParams(properties: properties, playerid: playerId), method: "Player.GetItem")
        genericRequest(request: itemRequest, completion: completion)
    }
    
    func playerGetPlayerProperties(params: PlayerPropertiesParams, completion: @escaping (CurrentProperties?, HTTPURLResponse?, Error?)->Void){
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.GetProperties")
        genericRequest(request: request, completion: completion)
    }
    
    /**
     Description: Retrieves current active Players
     up to 2 players could be active: Music plays and image are displayed on screen
     */
    func playerGetActivePlayers(completion: @escaping ([ActivePlayer]?, HTTPURLResponse?, Error? )-> Void){
        let urlRequest = URLRequest.kodiRequest(url: self.url, method: "Player.GetActivePlayers")
        genericRequest(request: urlRequest, completion: completion)
    }
    
    
    func playerSetShuffle(playerId: Int, shuffle: Bool, completion: @escaping (String?, HTTPURLResponse?, Error?)-> Void){
        let params = SetShuffleParams(playerid: playerId, shuffle: shuffle)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.SetShuffle")
        
        self.genericRequest(request: request, completion: completion)
    }
    
    func playerSetRepeat(playerId: Int, mode: RepeatMode, completion: @escaping (String?, HTTPURLResponse?, Error?)->Void){
        let params = SetRepeatParams(playerid: playerId, repeatMode: mode)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.SetRepeat")
        
        self.genericRequest(request: request, completion: completion)
    }
    
    func playerGoTo(playlistPosition: Int, playerId: Int, completion: @escaping (String?, HTTPURLResponse?, Error? )->Void){
        let params = GotoParams(playerid: playerId, to: playlistPosition)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.GoTo")
        
        genericRequest(request: request, completion: completion)
    }
    
    func playerOpen<ItemType: Codable>(libraryId: ItemType, completion: @escaping (String?, HTTPURLResponse?, Error? )->Void){
        
        let params = PlayerOpenParams(item: libraryId)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Player.Open")
        genericRequest(request: request, completion: completion)
    }
}


//MARK: Playlist Api
extension KodiPlayer{
    
    func playlistGetItems(params: PlaylistGetItemsParams, completion: @escaping (PlaylistGetItemsResponse?, HTTPURLResponse?, Error?)->Void){
        
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Playlist.GetItems")
        
        self.genericRequest(request: request, completion: completion)
    }
    
    func playListRemoveItem(playlistid: PlaylistId, item: Int, completion: @escaping (String?, HTTPURLResponse?, Error?) -> Void){
        let params = PlaylistRemoveItemParams(playlistid: playlistid, position: item)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Playlist.Remove")
        
        print("PlaylistremoveItem: RequestData: " + String(data: request.httpBody!, encoding: .utf8)!)
        
        self.genericRequest(request: request, completion: completion)
    }
    
    func playListAddItem<ItemType : Codable>(playlistId : PlaylistId, item: ItemType , completion: @escaping (String?, HTTPURLResponse?, Error? )-> Void){
        let params = PlaylistAddItemsParams(playlistid: playlistId, item: item)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Playlist.Add")
        self.genericRequest(request: request, completion:  completion)
    }
    
    func playListClear(playlistId: PlaylistId, completion: @escaping (String?, HTTPURLResponse?, Error?) -> Void){
        let params = PlaylistClearParams(playlistid: playlistId)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "Playlist.Clear")
        self.genericRequest(request: request, completion: completion)
    }
    
    
    func playlistGetPlaylists(completion: @escaping([PlayList]?, HTTPURLResponse?, Error? )->Void){
        let request = URLRequest.kodiRequest(url: self.url, method: "Playlist.GetPlaylists")
        self.genericRequest(request: request, completion: completion)
    }
}


//MARK: LibraryApi
extension  KodiPlayer{
    
    func libraryGetAlbums(properties: [AlbumProperties], limits: ListLimits, sort: ListSort, completion: @escaping (AlbumGetResponse?, HTTPURLResponse?, Error?) -> Void){
        let params = RequestAlbumsParams(properties: properties, limits: limits, sort: sort, includesingles: false, allroles: false)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "AudioLibrary.GetAlbums")
        self.genericRequest(request: request, completion: completion)
    }
    
    func libraryGetSongs(properties: [SongProperties], limits: ListLimits, sort: ListSort, completion: @escaping(GetSongsResponse?, HTTPURLResponse?, Error?)-> Void){
        let params = GetSongsParams(properties: properties, limits: limits, sort: sort)
        let request = URLRequest.kodiRequest(url: self.url, data: params, method: "AudioLibrary.GetSongs")
        self.genericRequest(request: request, completion: completion)
    }
    
    func libraryGetArtists(properties: ArtistsGetParams, completion: @escaping (ArtistGetResult?, HTTPURLResponse?, Error?)->Void){
        let artistRequest = URLRequest.kodiRequest(url: self.url, data: properties, method: "AudioLibrary.GetArtists")
        self.genericRequest(request: artistRequest, completion: completion)
    }
}
