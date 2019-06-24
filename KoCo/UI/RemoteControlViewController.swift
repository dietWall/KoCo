
//
//  RemoteControlViewController.swift
//  KoCo
//
//  Created by dietWall on 30.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


class RemoteControlViewController: UIViewController{

    enum NavigationButtonTags : Int{
        case Up
        case Right
        case Down
        case Left
        case Enter
        case Back
    }
    
    enum PlayerControlButtons : Int{
        case skipToStart
        case rewind
        case stop
        case pause
        case fastForward
        case skipToNext
        case shuffle
        case toggleRepeat
    }
    
    //MARK: Outlets
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var previewLabel: UILabel!
    
    @IBOutlet weak var percentageSlider: UISlider!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var playerStatusView: UIView!
    
    //MARK: Model
    var currentItem : AudioItem? = nil{
        didSet{
            print("RemoteControlViewController: item has been set")
            reloadItem()
            reloadImage()
            reloadGlobalTime()
        }
    }
    
    var audioPlayer : ActivePlayer? = nil{
        didSet{
            //print("RemoteControlViewController: audioplayer has been set")
            reloadPlayer()
        }
    }
    
    var totalTime : GlobalTime? = nil{
        didSet{
            //print("RemoteControlViewController: totalTime has been set")
            reloadGlobalTime()
        }
    }
    
    var currentTime : GlobalTime? = nil{
        didSet{
            //print("RemoteControlViewController: currentTime has been set")
            reloadCurrentTime()
            reloadPercentage()
        }
    }
    
    var percentage : Float? = nil{
        didSet{
            //print("RemoteControlViewController: percentage has been set")
            reloadPercentage()
        }
    }
    

    
    //MARK: ButtonEvents
    @IBAction func setVolume(_ sender: UISlider) {
        KodiPlayer.player?.setVolume(percentage: Int(sender.value*100.0), completion: {result, response, error in
            guard result != nil else {
                self.networkError(response: response, error: error)
                return
            }
        })
    }
    
    @IBAction func seekPosition(_ sender: UISlider) {
        
        let percentage = sender.value*100.00
        
        if let playerId = KodiPlayer.player?.activeAudioPlayer?.playerid{
            let params = SeekRequest(playerid: playerId, value: percentage)
            KodiPlayer.player?.seekPosition(params: params, completion: {
                result, response, error in
                guard result != nil else{
                    self.networkError(response: response, error: error)
                    return
                }
            })
        }
    }
    
    
    @IBAction func playerControlButtonPressed(_ sender: UIButton) {
        print("playerControll: \(sender.tag)")
        
        switch(sender.tag){
        case PlayerControlButtons.skipToStart.rawValue:
            KodiPlayer.player?.inputExecuteAction(for: .skipprevious, completion: directionKeyCompletion(result:response:error:))
        case PlayerControlButtons.rewind.rawValue:
            KodiPlayer.player?.inputExecuteAction(for: .rewind, completion: directionKeyCompletion(result:response:error:))
        case PlayerControlButtons.stop.rawValue:
            KodiPlayer.player?.inputExecuteAction(for: .stop, completion: directionKeyCompletion(result:response:error:))
        case PlayerControlButtons.pause.rawValue:
            KodiPlayer.player?.inputExecuteAction(for: .pause, completion: directionKeyCompletion(result:response:error:))
        case PlayerControlButtons.fastForward.rawValue:
            KodiPlayer.player?.inputExecuteAction(for: .fastforward, completion: directionKeyCompletion(result:response:error:))
        case PlayerControlButtons.skipToNext.rawValue:
            KodiPlayer.player?.inputExecuteAction(for: .skipnext, completion: directionKeyCompletion(result:response:error:))
        case PlayerControlButtons.toggleRepeat.rawValue:
            //usually we don´t need surrounding if here, because its not possible to press buttons
            //if no player is active. but be as safe as possible
            
            let newMode : RepeatMode
            
            switch(KodiPlayer.player?.currentProperties?.repeated){
            case .off?:
                newMode = .all
            case .all?:
                newMode = .one
            case .one?:
                newMode = .off
            case .none:
                newMode = .off
            }
            
            if let id = KodiPlayer.player?.activeAudioPlayer?.playerid{
                KodiPlayer.player?.setRepeat(playerId: id, mode: newMode, completion: directionKeyCompletion(result:response:error:))
            }
            
        case PlayerControlButtons.shuffle.rawValue:
            //usually we don´t need surrounding if here, because its not possible to press buttons
            //if no player is active. but be as safe as possible
            if let id = KodiPlayer.player?.activeAudioPlayer?.playerid{
                KodiPlayer.player?.setShuffle(playerId: id,
                                              shuffle: !(KodiPlayer.player?.currentProperties?.shuffled ?? true),       //negate old value, defaultValue: !true => false
                                              completion: directionKeyCompletion(result:response:error:))
            }
        default:
            print("unknown Sender Tag: \(sender.tag)")
        }
    }
    
    @IBAction func contextMenuPressed(_ sender: UIButton) {
        KodiPlayer.player?.inputExecuteAction(for: .contextmenu, completion: directionKeyCompletion(result:response:error:))
    }
    
    @IBAction func osdMenuPressed(_ sender: UIButton) {
        KodiPlayer.player?.inputExecuteAction(for: .osd, completion: directionKeyCompletion(result:response:error:))
    }
    
    @IBAction func directionKeyPressed(_ sender: UIButton) {
        
        switch(sender.tag){
        case NavigationButtonTags.Up.rawValue:
            KodiPlayer.player?.navigate(to: .Up, completion: directionKeyCompletion(result:response:error:))
        case NavigationButtonTags.Down.rawValue:
            KodiPlayer.player?.navigate(to: .Down, completion: directionKeyCompletion(result:response:error:))
        case NavigationButtonTags.Left.rawValue:
            KodiPlayer.player?.navigate(to: .Left, completion: directionKeyCompletion(result:response:error:))
        case NavigationButtonTags.Right.rawValue:
            KodiPlayer.player?.navigate(to: .Right, completion: directionKeyCompletion(result:response:error:))
        case NavigationButtonTags.Enter.rawValue:
            KodiPlayer.player?.navigate(to: .Enter, completion: directionKeyCompletion(result:response:error:))
        case NavigationButtonTags.Back.rawValue:
            KodiPlayer.player?.navigate(to: .Back, completion: directionKeyCompletion(result:response:error:))
        default:
            print("unknown button title : \(String(describing: sender.tag))")
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        KodiPlayer.player?.inputExecuteAction(for: .info, completion: directionKeyCompletion(result:response:error:))
    }
    
    //MARK: Observer Functions
    @objc func onPropertiesRefreshed(){
       
        if currentTime != KodiPlayer.player?.currentProperties?.time{
            currentTime = KodiPlayer.player?.currentProperties?.time
        }
        
        if percentage != KodiPlayer.player?.currentProperties?.percentage{
            percentage = KodiPlayer.player?.currentProperties?.percentage
        }
        
        reloadButtons()
    }
    
    
    
    @objc func onPlayerRefresh(){
        if audioPlayer != KodiPlayer.player?.activeAudioPlayer{
            audioPlayer = KodiPlayer.player?.activeAudioPlayer
        }
    }
    

        
    @objc func onItemRefreshed(){
        if currentItem != KodiPlayer.player?.currentItem{
            currentItem = KodiPlayer.player?.currentItem
        }
        if totalTime != KodiPlayer.player?.currentProperties?.totaltime{
            totalTime = KodiPlayer.player?.currentProperties?.totaltime
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPropertiesRefreshed), name: .propertiesRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayerRefresh), name: .playerRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onItemRefreshed), name: .itemChanged, object: nil)
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        audioPlayer = nil
        currentItem = nil
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
    }

    
    private func directionKeyCompletion(result: String?, response: HTTPURLResponse?, error: Error? ){
        guard let _ = result else {
            networkError(response: response, error: error)
            return
        }
        //Once Buttons are modified to give visual Feedback to user
        //return to normal state here
        
    }

    
    //MARK: Change UI Appearance if Status changed
    func reloadPlayer(){
        if audioPlayer != nil {
            DispatchQueue.main.async { [weak self] in
                self?.playerStatusView.isHidden = false
            }
        }
        else {
            DispatchQueue.main.async { [weak self] in
                self?.playerStatusView.isHidden = true
            }
            
        }
    }
    
    func reloadImage(){
        guard let item = currentItem else{
            setImage(img: nil)
            return
        }
        
        let path = item.thumbnail
        
        if  path != nil ||  path == ""{
            //generate img
            let img = UIImage.imageWith(name: item.artist?[0])
            setImage(img: img)
            //setImage(img: nil)
            return
        }
        
        //We have an image
        KodiPlayer.player?.fileDownload(kodiFileUrl: path!, completion: {
            data, response, error in
            
            guard let data = data else {
                print("reloadimg error while downloading image")
                self.networkError(response: response, error: error)
                return
            }
            
            if let img = KodiPlayer.player?.getImage(kodiFileUrl: data.details.path){
                self.setImage(img: img)
            }
        })
        
    }
    
    func reloadItem(){
        guard let item = currentItem else {
            self.setText(text: "")
            //self.setImage(url: nil)
            return
        }
        
        self.setText(text: item.getFormated())
    }
    
    
    func reloadButtons(){
        
        if let shuffled = KodiPlayer.player?.currentProperties?.shuffled{
            if shuffled == true{
                DispatchQueue.main.async { [weak self] in
                    self?.shuffleButton.imageView?.image = #imageLiteral(resourceName: "shuffle-50")
                }
            }
            else{
                DispatchQueue.main.async { [weak self] in
                    self?.shuffleButton.imageView?.image = #imageLiteral(resourceName: "shuffle-grey-50")
                }
            }
        }
        
        if let repeated = KodiPlayer.player?.currentProperties?.repeated{
            let img : UIImage
            
            switch(repeated){
            case .off:
                img = #imageLiteral(resourceName: "repeat-grey")
            case .one:
                img = #imageLiteral(resourceName: "repeat-one-50")
            case .all:
                img = #imageLiteral(resourceName: "repeat-50")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.repeatButton.imageView?.image = img
            }
        }
    }
    
    func reloadGlobalTime(){
        guard let totalTime = totalTime else{
            DispatchQueue.main.async { [weak self] in
                self?.totalTimeLabel.text = "00:00"
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.totalTimeLabel.text = totalTime.getFormatted()
        }
    }
    
    func reloadPercentage(){
        guard let value = percentage else{
            DispatchQueue.main.async { [weak self] in
                self?.percentageSlider.value = 0.0
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            //print("percentage set: \(value)")
            self?.percentageSlider.value = value/100
        }
        
    }
    
    func reloadCurrentTime(){
        guard let time = currentTime else{
            DispatchQueue.main.async { [weak self] in
                self?.currentTimeLabel.text = "00:00"
            }
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.currentTimeLabel.text = time.getFormatted()
        }
    }
    
    //MARK: Some Helper Functions
    
    private func setImage(img: UIImage?){
        DispatchQueue.main.async { [weak self] in
            self?.previewImage.image = img
        }
    }
    
    
    private func setImage(url: String?){
        guard let url = url else{
            DispatchQueue.main.async { [weak self] in
                self?.previewImage.image = nil
            }
            return
        }
        
        if url == ""{
            DispatchQueue.main.async { [weak self] in
                self?.previewImage.image = nil
            }
            return
        }
        
        KodiPlayer.player?.fileDownload(kodiFileUrl: url, completion: {
            data, response, error in
            
            guard let data = data else {
                print("data: nil")
                return
            }
            
            if let img = KodiPlayer.player?.getImage(kodiFileUrl: data.details.path){
                DispatchQueue.main.async { [weak self] in
                    self?.previewImage.image = img
                }
            }
        })
    }
    
    private func setText(text: String){
        DispatchQueue.main.async { [weak self] in
            self?.previewLabel.text = text
        }
    }
}
