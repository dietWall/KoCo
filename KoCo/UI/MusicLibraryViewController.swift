//
//  MusicLibraryViewController.swift
//  KoCo
//
//  Created by admin on 02.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class MusicLibraryViewController: UIViewController, KodiPlayerViewController, UITableViewDataSource {
    

    
    var player: KodiPlayer?
    
    @IBOutlet weak var mediaLibraryView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(player != nil){
            print("MusicLibraryViewController" + (player?.name)!)
        }
        else
        {
            print("MusicLibraryViewController" + "player not set" )
        }
        // Do any additional setup after loading the view.
        mediaLibraryView.dataSource = self
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: new Cell and reformat
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicPlayerCell", for: indexPath)
        
        // Configure the cell...
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
