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
        
        //navigationItem.title = "Media Centers"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
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


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        KodiPlayer.player = mediaPlayers[indexPath.row]
        
        let tbvc = self.tabBarController as! KodiPlayerTabBarViewController
        //Select RemoteViewController as active ViewController
        tbvc.selectedIndex = 1
    }

}
