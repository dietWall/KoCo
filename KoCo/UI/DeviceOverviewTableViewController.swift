//
//  DeviceOverviewTableViewController.swift
//  KoCo
//
//  Created by dietWall on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


class DeviceOverviewTableViewController: UITableViewController{
    
    var player: KodiPlayer?
    
    var mediaPlayers = [KodiPlayer](){
        didSet{
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Media Centers"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mediaPlayers.loadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaPlayers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicPlayerCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = mediaPlayers[indexPath.row].name
        cell.detailTextLabel?.text = mediaPlayers[indexPath.row].host
        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            mediaPlayers.remove(at: indexPath.row)
            mediaPlayers.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            //Von hier könnte auch ein Segue stattfinden
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            performSegue(withIdentifier: "AddNewKodiPlayer", sender: self)
        }    
    }
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        KodiPlayer.player = mediaPlayers[indexPath.row]
        
        let tbvc = self.tabBarController
        //Select RemoteViewController as active ViewController
        tbvc?.selectedIndex = 1
        //make Bottom bar visible. => At start user is forced to choose a player for singleton
        self.tabBarController?.tabBar.isHidden = false
    }

}
