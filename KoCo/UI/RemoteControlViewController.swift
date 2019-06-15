
//
//  RemoteControlViewController.swift
//  KoCo
//
//  Created by dietWall on 30.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


class RemoteControlViewController: UIViewController{

    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var previewLabel: UILabel!
    
    @IBOutlet weak var percentageSlider: UISlider!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var playerStatusView: UIView!

    
    //Timer for activePlayerStatus
    var timer : Timer?
    
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
    
    var activePlayer = [ActivePlayer](){
        didSet{
            if activePlayer.count == 0{
                DispatchQueue.main.async { [weak self] in
                    self?.playerStatusView.isHidden = true
                }
            }
            else{
                fillItemView()
                fillPlayerProperties()
                DispatchQueue.main.async { [weak self] in
                    self?.playerStatusView.isHidden = false
                }
            }
        }
    }
    
    var activeAudioPlayer : ActivePlayer?{
        get{
            return self.activePlayer.filter{$0.type == "audio"}[0]
        }
    }
    
    var currentProperties : CurrentProperties?{

        didSet{
            //Update UI: Maybe better in a function??
            if(currentProperties?.time != nil){
                DispatchQueue.main.async { [weak self] in
                    self?.currentTimeLabel.text = self?.currentProperties?.time?.getFormatted()
                }
            }
            if(currentProperties?.totaltime != nil){
                DispatchQueue.main.async { [weak self] in
                    self?.totalTimeLabel.text = self?.currentProperties?.totaltime?.getFormatted()
                }
            }
            
            if(currentProperties?.percentage != nil){
                DispatchQueue.main.async { [weak self] in
                    self?.percentageSlider.value = ((self?.currentProperties?.percentage!)!) / 100.00
                }
            }
            
            if let shuffled = currentProperties?.shuffled{
                if shuffled == true{
                    DispatchQueue.main.async { [weak self] in
                        //self?.shuffleButton.imageView?.image = UIImage(named: "shuffle-50")
                        self?.shuffleButton.imageView?.image = #imageLiteral(resourceName: "shuffle-50")
                    }
                }
                else{
                    DispatchQueue.main.async { [weak self] in
                        //self?.shuffleButton.imageView?.image = UIImage(named: "shuffle-grey-50")
                        self?.shuffleButton.imageView?.image = #imageLiteral(resourceName: "shuffle-grey-50")
                    }
                }
            }
            
            
            if let repeated = currentProperties?.repeated{
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
    }
    
    
    
    func fillPlayerProperties(){
        let props : [PlayerProperties] = [.canshuffle, .percentage, .playlistid, .position, .time, .totaltime, .repeated, .shuffled]
        
        guard let id = activeAudioPlayer?.playerid else {
            //Nothing playing now
            return
        }
        
        let params = PlayerPropertiesRequest(playerid: id, properties: props)
        KodiPlayer.player?.getPlayerProperties(params: params, completion: {
            result, response, error in
            
            guard let result = result else {
                print("FillPlayerProperties: irgendwas undefiniertes passiert hier")
                return
            }
            
            self.currentProperties = result
        })
    }
    
    func fillItemView(){
        if let playerId = activeAudioPlayer?.playerid{
            
            let requestProps :[ListFiedsAll] = [.artist, .albumartist, .album, .displayartist, .showtitle, .fanart, .thumbnail, .track, .title, .art]
            
            KodiPlayer.player?.getCurrentItem(properties: requestProps, playerId: playerId, completion:
                {result, response, error in
                    guard let result = result else{
                        return
                    }
                    
                    self.setText(text: result.item.getFormated())
                    self.setImage(url: result.item.thumbnail)
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshPlayerStatus()      //refresh first time and start Timer
    }
    

    

    //MARK: ButtonEvents
    @IBAction func playerControlButtonPressed(_ sender: UIButton) {
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
            
            switch(currentProperties?.repeated){
            case .off?:
                newMode = .all
            case .all?:
                newMode = .one
            case .one?:
                newMode = .off
            case .none:
                newMode = .off
            }
            
            if let id = self.activeAudioPlayer?.playerid{
                KodiPlayer.player?.setRepeat(playerId: id, mode: newMode, completion: directionKeyCompletion(result:response:error:))
            }
        case PlayerControlButtons.shuffle.rawValue:
            //usually we don´t need surrounding if here, because its not possible to press buttons
            //if no player is active. but be as safe as possible
            
            if let id = self.activeAudioPlayer?.playerid{
                KodiPlayer.player?.setShuffle(playerId: id, shuffle: !(self.currentProperties?.shuffled ?? true) , completion: directionKeyCompletion(result:response:error:))
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
    
    
    private func directionKeyCompletion(result: String?, response: HTTPURLResponse?, error: Error? ){
        if result != nil{
            return
        }
        else{
            if let response = response{
                
                let connectionFailedNotification = Notification(title: "Internal Error", alertStyle: .alert, message: "Error: " + String(response.statusCode), actions: [NotificationButton(text: "Ok", style: .default)] )
                
                self.createNotification(notification: connectionFailedNotification)
            }
            else{
                let errorstring = error?.localizedDescription ?? "No Response from host"
                
                let internalErrorNotification  = Notification(title: "Internal Error", alertStyle: .alert, message: "Error: " + errorstring, actions: [NotificationButton(text: "Ok", style: .default)] )
                
                createNotification(notification: internalErrorNotification)
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Timer must be invalidated, otherwise it will keep us in memory
        self.timer?.invalidate()
    }
    

    @objc func refreshPlayerStatus(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(refreshPlayerStatus)), userInfo: nil, repeats: false)
        KodiPlayer.player?.getPlayerStatus(completion: { players, response, error in
            if response?.statusCode == 200{
                self.activePlayer = players!
            }
            else{   //Network Error or something else
                self.timer?.invalidate()                        //It doesn´t make sense to refresh from now on
                guard response != nil else{
                    let errorstring = error?.localizedDescription ?? "No Response from host"
                    
                    let connectionFailedNotification = Notification(title: "Internal Error", alertStyle: .alert, message: "Error: " + errorstring, actions: [NotificationButton(text: "Ok", style: .default)] )
                    self.createNotification(notification: connectionFailedNotification)
                    return
                }
                let connectionFailedNotification = Notification(title: "Internal Error", alertStyle: .alert, message: "Error: ", actions: [NotificationButton(text: "Ok", style: .default)] )
                self.createNotification(notification: connectionFailedNotification)
                }
            })
    }
    
    
    
    @IBAction func setVolume(_ sender: UISlider) {
        KodiPlayer.player?.setVolume(percentage: Int(sender.value*100.0)
            , completion: {result, response, error in
                guard let result = result else {
                    print("setVolume: result = nil")
                    return
                }
                
                print("Volume set: \(result)")
        })
        
    }
    
    @IBAction func seekPosition(_ sender: UISlider) {
        let percentage = sender.value*100.00
        
        if let playerId = self.activeAudioPlayer?.playerid{
            let params = SeekRequest(playerid: playerId, value: percentage)
            KodiPlayer.player?.seekPosition(params: params, completion: {_,_,_ in })
        }
    }
    
    
    private func setImage(url: String){
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
    
    private func formatText(item: AudioItem) -> String{
        var result = String()
        result.append((item.label) + "\n")
        result.append((item.albumartist[0]) + "\n")
        result.append((item.album) + "\n")
        return result
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue")
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


