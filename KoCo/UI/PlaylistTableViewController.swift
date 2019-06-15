//
//  PlaylistTableViewController.swift
//  KoCo
//
//  Created by dietWall on 02.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController{
    
    //var playList : String?
    
    var activeAudioPlayer : ActivePlayer?{
        didSet{
            //download Playlist
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        KodiPlayer.player?.getPlayerStatus(completion: {
            result, response, error in
            
            guard let result = result else {
                //TODO Error to User
                return
            }
            
            self.activeAudioPlayer = result.filter{ $0.type == "audio" }[0]
            
        })
    }

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */



    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
