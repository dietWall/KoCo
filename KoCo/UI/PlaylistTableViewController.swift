//
//  PlaylistTableViewController.swift
//  KoCo
//
//  Created by dietWall on 02.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


class PlaylistTableViewController: UITableViewController{
    
    var activePlayer : ActivePlayer?
    
    var playlistElementsCount : Int?{
        didSet{
            print("PlaylistViewController: count changed")
        }
    }
    var playlistId : Int?{
        didSet{
            print("PlaylistViewcontroller: PlaylistId changed")
        }
    }
    var currentItemNr : Int?{
        didSet{
            print("PlaylistViewcontroller: Item changed")
        }
    }
    
    //A very special case: playlist replaced, but count is the same
    var currentItem : AudioItem?

    var shuffled : Bool?{
        didSet{
            print("PlaylistViewcontroller: shuffled changed")
        }
    }
    
    
    func reload(){
        print("PlaylistViewController: Reload")
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
         navigationItem.title = KodiPlayer.player?.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(statusRefreshed), name: .statusRefreshedNotificaten, object: nil)
        
        //navigationItem.title = KodiPlayer.player?.name

    }
    
    
    @objc func statusRefreshed(){
        print("Playlist: Refreshed")
        var updateTable = false
        
        if activePlayer != KodiPlayer.player?.activeAudioPlayer{
            updateTable = true
            activePlayer = KodiPlayer.player?.activeAudioPlayer
        }
        
        if playlistId != KodiPlayer.player?.currentProperties?.playlistid{
            updateTable = true
            playlistId = KodiPlayer.player?.currentProperties?.playlistid
        }
        
        if shuffled != KodiPlayer.player?.currentProperties?.shuffled{
            updateTable = true
            shuffled = KodiPlayer.player?.currentProperties?.shuffled
        }
        
        if playlistElementsCount != KodiPlayer.player?.playlist?.count{
            updateTable = true
            playlistElementsCount = KodiPlayer.player?.playlist?.count
        }
        
        if currentItemNr != KodiPlayer.player?.currentProperties?.position{
            updateTable = true
            currentItemNr = KodiPlayer.player?.currentProperties?.position
        }
        
        if currentItem != KodiPlayer.player?.currentItem{
            updateTable = true
            currentItem = KodiPlayer.player?.currentItem
        }
        
        if(updateTable){
            reload()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Special case: No Player, but playlist is not empty
        //It happens, when stopped while playing
        if KodiPlayer.player?.activeAudioPlayer == nil{
            return 0
        }
        
        //otherwise: current playlist.count, if not available : 0
        return KodiPlayer.player?.playlist?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell2", for: indexPath)
        
        if let item = KodiPlayer.player?.playlist?[indexPath.row]{
            cell.textLabel?.text = item.getFormated()
            
            if let id = item.id{
                if let path = KodiPlayer.player?.imagePaths[id]{
                    print("item has path")
                    if let image = KodiPlayer.player?.getImage(kodiFileUrl: path){
                        print("got image")
                        cell.imageView?.image = image
                        cell.imageView?.contentMode = .scaleAspectFill
                        
                    }
                }
                //No image available: generate one
                else{
                    if let artistName = item.artist?[0]{
                        cell.imageView?.image =  UIImage.imageWith(string: artistName)
                    }
                    
                }
            }
            
            if indexPath.row == KodiPlayer.player?.currentProperties?.position{
                cell.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
            else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        return cell
    }
    



    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Assure we are not playing the deleting track, otherwise kodi will report an error
            
            if indexPath.row == currentItemNr{
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.removeItem(itemNr: indexPath)
            }
            
        }
    }

    private func removeItem(itemNr: IndexPath){
        KodiPlayer.player?.playListRemoveItem(playlistid: (KodiPlayer.player?.currentProperties?.playlistid)!, item: itemNr.row, completion: {
            result, response, error in
            
            guard let result = result else{
                self.networkError(response: response, error: error)
                return
            }
            if result != "OK"{
                self.resultError()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Playlist Items will be kept in Playlist if player stopped
        if KodiPlayer.player?.activeAudioPlayer != nil{
            KodiPlayer.player?.playerGoTo(playlistPosition: indexPath.row, playerId: (KodiPlayer.player?.activeAudioPlayer?.playerid)!, completion: {
                result, response, error in
                
                
            })
        }
        
    }

}
