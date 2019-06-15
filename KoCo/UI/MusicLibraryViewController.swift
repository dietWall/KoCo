//
//  MusicLibraryViewController.swift
//  KoCo
//
//  Created by admin on 02.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class MusicLibraryViewController: UIViewController, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    var artistCount : Int = 0
    
    var fetching : Bool = false
    
    var artists = [ArtistReturn](){
        didSet{
            DispatchQueue.main.async { [weak self] in
                self?.mediaLibraryView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var mediaLibraryView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mediaLibraryView.dataSource = self
        //mediaLibraryView.prefetchDataSource = self
    
        //loadArtists(first: 0, last: 422)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArtists(first: 0, last: 422)
    }
    
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: new Cell and reformat
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicMediaCell", for: indexPath)
        
        cell.textLabel?.text = artists[indexPath.row].artist
        
        // Configure the cell...
        return cell
    }
    
    //MARK: Prefetch
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //Laden:
        print("\(indexPaths.count)")
        
        loadArtists(first: indexPaths[0].row, last: (indexPaths.last?.row)!)
        
        print("started loading with: [\(indexPaths[0].row)...\(String(describing: indexPaths.last?.row))]")
    }
    
    
    
    func loadArtists(first: Int, last: Int){
        if(fetching == false)
        {
            fetching = true
            let properties : [ArtistProperties] = [.thumbnail, .fanart, .born ]
            
            //let properties : [ArtistProperties] = [.thumbnail, .fanart, .born, .formed, .died, .disbanded, .yearsactive, .mood, .style, .genre ]
            
            let limits = ListLimits(start: first, end: last, total: nil)
            
            let sortType = SortType(order: Order(rawValue: "ascending")!, method: "artist", ignorearticle: true)
            
            let request = ArtistsGet(properties: properties, limits: limits, sort: sortType)
            
            KodiPlayer.player?.getArtists(properties: request){
                result, response, error in
                //TODO
                if let result = result{
                    print("ArtistRequest fertig: result.count: \(String(describing: result.artists?.count))")
                    self.artists = result.artists!
                }
                
                if let count = result?.limits.total{
                    self.artistCount = count
                }
                
                self.fetching = false
            }
        }
        else{
            print("already fetching")
        }
        
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
