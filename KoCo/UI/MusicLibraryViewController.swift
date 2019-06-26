//
//  MusicLibraryViewController.swift
//  KoCo
//
//  Created by dietWall on 02.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class MusicLibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MusikLibraryCellDelegate{
    
    @IBOutlet var contextButtons: [UIButton]!
    
    enum Context : Int{
        case artists
        case albums
        case songs
        case playlists
    }
    
    var context : Context = .artists{
        didSet{
            reload()
            updateButtons(sender: contextButtons[context.rawValue])
        }
    }
    
    var artists = [AudioDetailsArtist](){
        didSet{
            reload()
        }
    }
    
    var artistFilter : LibraryId?
    
    var albumsLibrary = [AudioDetailsAlbum](){
        didSet{
            print("albums loaded total: \(albumsLibrary.count) albums")
        }
    }
    
    var playlists : [PlayList]?
    
    var albumFilter : LibraryId? = nil
    
    var songs = [SongDetails]()
    
    var activePlayer : ActivePlayer? = nil{
        didSet{
            loadLibrary()
        }
    }
    
    
    @IBOutlet weak var mediaLibraryView: UITableView!
    
    func addButtonPressed(cell: MusicLibraryCell) {
        print("Add \(String(describing: cell.textLabel?.text))) to Playlist")
        addCellIdToCurrentPlaylist(cell: cell)
    }
    
    func addCellIdToCurrentPlaylist(cell: MusicLibraryCell){
        guard let id = cell.mediaId else {
            print("Interal Error: Cell has no mediaId")
            return
        }
        
        switch(context)
        {
        case .artists:
            print("artist")
            addArtistToCurrentPlaylist(artist: id)
        case .albums:
            addAlbumToCurrentPlaylist(album: id)
            print("album")
        case .songs:
            addSongToCurrentPlaylist(song: id)
            print("song")
        case .playlists:
            print("playlist")
        }
    }
    
    func playButtonPressed(cell: MusicLibraryCell) {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        KodiPlayer.player?.playListClear(playlistId: KodiPlayer.player?.currentProperties?.playlistid ?? 0, completion: {
            result, response, error in
            guard let result = result else{
                print("Could not clear Playlist")
                print("Statuscode: \(String(describing: response?.statusCode))")
                
                print("Error: \(String(describing: error))")
                return
            }
            if result != "OK"{
                
            }
            semaphore.signal()
        })
        
        semaphore.wait()
        
        switch context {
        case .artists:
            play(artist: cell.mediaId!)
        case .albums:
            play(album: cell.mediaId!)
        case .songs:
            print("Playing song with id: \(String(describing: cell.mediaId))")
            play(song: cell.mediaId!)
        default:
            print("internal Error: No Context")
            context = .artists
        }
        
    }
    
    func play(artist: LibraryId){
        let params = AddArtistId(artistid: artist)
        KodiPlayer.player?.playerOpen(libraryId: params, completion: {_,_,_ in})
    }
    
    func play(album: LibraryId){
        let params = AddAlbumId(albumid: album)
        
        KodiPlayer.player?.playerOpen(libraryId: params, completion: {_,_,_ in})
    }
    
    func play(song: LibraryId){
        let params = AddSongId(songid: song)
        
        print("songid: \(song)")
        print(String(describing: songs.filter({$0.songid == song})))
        
        KodiPlayer.player?.playerOpen(libraryId: params, completion: {
            result, response, error in
            guard let result = result else{
                self.networkError(response: response, error: error)
                print("AddSong: result failed")
                return
            }
            if result == "OK"{
                print("play: result ok")
                return
            }
            
            print("Result != OK : \(result)")
            
            
            
        })
    }
    

    
    

    func updateButtons(sender: UIButton){
        for button in contextButtons{
            if button == sender{
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: UIControl.State.normal)
            }
            else{
                button.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        updateButtons(sender: sender)
        
        switch(sender.titleLabel?.text){
        case "Artists":
            context = .artists
        case "Albums":
            artistFilter = nil
            context = .albums
        case "Songs":
            artistFilter = nil
            albumFilter = nil
            context = .songs
        case "Playlists":
            context = .playlists
        default:
            context = .artists
            print("unknown Button: \(String(describing: sender.titleLabel?.text))")
        }
        
        print("new? context: \(self.context)")
        //todo: some reformat for sender to show feedback to user
    }
    
    
    func reload(){
        DispatchQueue.main.async { [weak self] in
            self?.mediaLibraryView.reloadData()
        }
    }
    
    func loadLibrary(){
        DispatchQueue.global(qos: .userInitiated).async{
            self.loadArtistst()
            self.loadAlbums()
            self.loadSongs()
            self.loadPlaylists()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mediaLibraryView.dataSource = self
        mediaLibraryView.delegate = self
        loadLibrary()
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        navigationItem.title = KodiPlayer.player?.name
    }
    
    
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch context {
        case .artists:
            return artists.count
        case .albums:
            return filteredAlbums.count
        case .songs:
            return filteredSongs.count
        case .playlists:
            guard let count = audioPlaylist?.count else{
                return 0
            }
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MusicLibraryCell
        cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath) as! MusicLibraryCell
        
         // Configure the cell depending on current context
        switch(context){
        case .artists:
            fillArtist(cell: cell, artist: artists[indexPath.row])
        case .albums:
            fillAlbum(cell: cell, album: filteredAlbums[indexPath.row])
        case .songs:
            print("set song at \(indexPath.row) :  \(filteredSongs[indexPath.row])")
            fillSong(cell: cell, song: filteredSongs[indexPath.row])
        case .playlists:
            guard let playlist = audioPlaylist?[indexPath.row] else{
                cell.textLabel?.text = "Internal Error"
                return cell
            }
            fillPlaylist(cell: cell, playlist: playlist )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(context){
        case .artists:
            print("switch to .albums with: \(String(describing: artists[indexPath.row].artist))")
            artistFilter = artists[indexPath.row].artistid
            context = .albums
        case .albums:
            print("switch to .songs with: \(String(describing: albumFilter))")
            albumFilter = filteredAlbums[indexPath.row].albumid
            context = .songs
        case .songs:
            print("selected song with: \(String(describing: songs[indexPath.row].title))")
        case .playlists:
            print("selected playlist at: \(indexPath.row)")
        }
    }
    
    func fillPlaylist(cell: MusicLibraryCell, playlist: PlayList){
        print("FillPlaylist with: \(String(describing: playlist))")
        cell.delegate = self
        cell.mediaId = playlist.playlistid
        cell.textLabel?.text = "Remote Musicplaylist \(playlist.playlistid)"
    }
    
    func fillArtist(cell: MusicLibraryCell, artist: AudioDetailsArtist){
        print("FillArtist with: \(String(describing: artist.artist))")
        cell.delegate = self
        cell.mediaId = artist.artistid
        cell.textLabel?.text = artist.artist
    }
    
    func fillAlbum(cell: MusicLibraryCell, album: AudioDetailsAlbum){
        print("FillAlbum with: \(String(describing: album.title))")
        cell.delegate = self
        cell.mediaId = album.albumid
        cell.textLabel?.text = album.title
    }
    
    func fillSong(cell: MusicLibraryCell, song: SongDetails){
        print("FillAlbum with: \(String(describing: song.title))")
        cell.delegate = self
        cell.mediaId = song.songid
        cell.textLabel?.text = song.title
    }
    

}


//MARK: LibraryModell
extension MusicLibraryViewController{
    
    var audioPlaylist : [PlayList]?{
        get{
            return playlists?.filter( {$0.type == "audio"} )
        }
    }
    
    var filteredAlbums : [AudioDetailsAlbum]{
        get{
            guard let artistFilter = artistFilter else {
                //No Filter set: return library
                return albumsLibrary
            }
            //Filter is set: return filtered
            return albumsLibrary.filter({
                guard let result = $0.artistid?.contains(artistFilter) else {
                    return false
                }
                return result
            })
        }
    }
    
    var filteredSongs : [SongDetails]{
        get{
            if let albumFilter = albumFilter{
                //Filter only with album
                print("filtering songs with: \(albumFilter)")
                let result =  songs.filter({ $0.albumid == albumFilter})
                print(result)
                return result
            }
            else {
                //No Filters active
                return songs
            }
        }
    }
    
    
    func loadArtistst(){
        
        let firstResult = getArtistsSynchronous(start: 0, end: 500)
        guard let result = firstResult else {
            self.artists = [AudioDetailsArtist]()
            return
        }
        
        if result.limits.total > 500{
            let realResult = getArtistsSynchronous(start: 0, end: result.limits.total)
            
            guard let result = realResult else {
                self.artists = [AudioDetailsArtist]()
                return
            }
            artists = result.artists
        }
        else{
            self.artists = result.artists
        }
    }
    
    func loadAlbums(){
        let firstResult = getAlbumsSynchronous(start: 0, end: 500)
        guard let result = firstResult else {
            self.albumsLibrary = [AudioDetailsAlbum]()
            return
        }
        
        if result.limits.total > 500{
            let realResult = getAlbumsSynchronous(start: 0, end: result.limits.total)
            guard let result = realResult else {
                self.artists = [AudioDetailsArtist]()
                return
            }
            albumsLibrary = result.albums
        }
        else{
            self.albumsLibrary = result.albums
        }
    }
    
    func loadSongs(){
        let firstResult = getSongsSynchronous(first: 0, last: 500)
        
        guard let result = firstResult else {
            self.songs = [SongDetails]()
            return
        }
        
        if result.limits.total > 500{
            let realResult = getSongsSynchronous(first: 0, last: result.limits.total)
            
            guard let result = realResult else {
                self.songs = [SongDetails]()
                return
            }
            songs = result.songs
        }
        else{
            self.songs = result.songs
        }
    }
    
    
    func loadPlaylists(){
        KodiPlayer.player?.playlistGetPlaylists(completion: {
            result, response, error in
            
            guard let result = result else {
                print("loadPlaylists: No Result")
                return
            }
            self.playlists = result
        })
    }
    
    private func getArtistsSynchronous(start: Int, end: Int) -> ArtistGetResult?{
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        var requestResult : ArtistGetResult? = nil
        
        let properties : [ArtistProperties] = [.thumbnail, .fanart, .born ]
        let limits = ListLimits(start: start, end: end, total: nil)
        let sortType = ListSort(order: Order(rawValue: "ascending")!, method: "artist", ignorearticle: true)
        let request = ArtistsGetParams(properties: properties, limits: limits, sort: sortType)
        
        KodiPlayer.player?.libraryGetArtists(properties: request){
            result, response, error in
            guard let result = result else{
                self.networkError(response: response, error: error)
                semaphore.signal()
                return
                
            }
            requestResult = result
            semaphore.signal()
        }
        
        semaphore.wait()
        return requestResult
    }
    
    private func getAlbumsSynchronous(start: Int, end: Int) -> AlbumGetResponse?{
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        var requestResult : AlbumGetResponse? = nil
        
        let properties : [AlbumProperties] = [ .title, .artist, .genre, .type, .albumlabel, .thumbnail, .artistid]
        let limits = ListLimits(start: start, end: end, total: nil)
        let sortType = ListSort(order: Order(rawValue: "ascending")!, method: "artist", ignorearticle: true)
        
        
        KodiPlayer.player?.libraryGetAlbums(properties: properties, limits: limits, sort: sortType){
            result, response, error in
            guard let result = result else{
                self.networkError(response: response, error: error)
                semaphore.signal()
                return
                
            }
            requestResult = result
            semaphore.signal()
        }
        
        semaphore.wait()
        return requestResult
    }
    
    
    func getSongsSynchronous(first: Int, last: Int)-> GetSongsResponse?{
        
        let properties: [SongProperties] = [.title, .artist, .artistid, .fanart, .thumbnail, .albumid, .album, .albumartistid ]
        let limits = ListLimits(start: first, end: last, total: nil)
        let sorttype = ListSort(order: Order(rawValue: "ascending")!, method: "artist", ignorearticle : true)
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        var songs : GetSongsResponse? = nil
        
        KodiPlayer.player?.libraryGetSongs(properties: properties, limits: limits, sort: sorttype, completion: {
            result, response, error in
            guard let result = result else{
                self.networkError(response: response, error: error)
                semaphore.signal()
                return
            }
            
            songs = result
            semaphore.signal()
            //self.songs = result.songs
            
        })
        
        semaphore.wait()
        return songs
    }
    
    func addSongToCurrentPlaylist(song : LibraryId){
        if let playlistId = KodiPlayer.player?.currentProperties?.playlistid
        {
            let item = AddSongId(songid: song)
            KodiPlayer.player?.playListAddItem(playlistId: playlistId, item: item, completion: {
                result, response, error in
                
                guard let result = result else {
                    return
                }
                if result == "OK"{
                    //Ok
                }
                print("Result != Ok")
                print("\(result)")
            })
        }
    }
    
    func addAlbumToCurrentPlaylist(album : LibraryId){
        if let playlistId = KodiPlayer.player?.currentProperties?.playlistid
        {
            let item = AddAlbumId(albumid: album)
            KodiPlayer.player?.playListAddItem(playlistId: playlistId, item: item, completion: {
                result, response, error in
                
                guard let result = result else {
                    return
                }
                if result == "OK"{
                    //Ok
                }
                print("Result != Ok")
                print("\(result)")
            })
        }
    }
    
    func addArtistToCurrentPlaylist(artist : LibraryId){
        if let playlistId = KodiPlayer.player?.currentProperties?.playlistid
        {
            let item = AddArtistId(artistid: artist)
            
            KodiPlayer.player?.playListAddItem(playlistId: playlistId, item: item, completion: {
                result, response, error in
                guard let result = result else {
                    return
                }
                if result == "OK"{
                    //Ok
                }
                print("Result != Ok")
                print("\(result)")
            })
        }
    }
}
