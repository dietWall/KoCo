//
//  DeviceOverviewTableViewController.swift
//  KoCo
//
//  Created by dietWall on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

protocol KodiPlayerLoaderProtocol{
    func loadData() -> [KodiPlayer]
}


extension KodiPlayerLoaderProtocol{
    
    func loadData() -> [KodiPlayer]{
        
        var url: URL
        
        do{
            url = try FileManager.default.url(
                for: FileManager.SearchPathDirectory.applicationDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            
            url.appendPathComponent("players.json")
            
            if let data = try? Data(contentsOf: url){
                let decoder = JSONDecoder()
                
                let result = try decoder.decode([KodiPlayer].self, from: data)
                
                print(result.count)
                
                return result
            }else{
                
            }
        }
        catch let error{
            print("Filemanager hat geschmissen: \(error)")
        }
        return [KodiPlayer]()           //not found, error, etc: return an empty array
    }
}



class DeviceOverviewTableViewController: UITableViewController, KodiPlayerLoaderProtocol {
   
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mediaPlayers = loadData()
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
        cell.detailTextLabel?.text = mediaPlayers[indexPath.row].url
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}





