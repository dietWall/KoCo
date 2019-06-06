
//
//  RemoteControlViewController.swift
//  KoCo
//
//  Created by dietWall on 30.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


class KodiInstance{
    
}

class RemoteControlViewController: UIViewController{
   
    enum NavigationButtonTags : Int{
        case Up
        case Right
        case Down
        case Left
        case Enter
        case Back
    }
    
    
    //var player : KodiPlayer? = KodiPlayer.player
    
    //Timer for activePlayerStatus
    var timer : Timer?
    
    @IBOutlet weak var playerStatusView: UIView!
    
    private func directionKeyCompletion(result: String?, response: HTTPURLResponse?, error: Error? )
    {
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
        
        switch(sender.tag)
        {
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

    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(refreshPlayerStatus)), userInfo: nil, repeats: true)
        
        //self.player = KodiPlayer.player
        
        //print("RemoteControlView: selected player: \(String(describing: self.player?.name))")
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        KodiPlayer.player?.inputExecuteAction(for: .info, completion: directionKeyCompletion(result:response:error:))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if(player != nil){
//            print("RemoteControlViewController" + (player?.name)!)
//        }
//        else
//        {
//            print("RemoteControlViewController " + "player not set" )
//        }
        // Do any additional setup after loading the view.
        
        self.refreshPlayerStatus()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Timer must be invalidated, otherwise it will keep us in memory
        self.timer?.invalidate()
    }
    

    @objc func refreshPlayerStatus(){
        
        //print("Refresh: \(String(describing: player?.name))")
        
        KodiPlayer.player?.getPlayerStatus(completion: { players, response, error in
            if response?.statusCode == 200{
                if players?.count == 0{
                    DispatchQueue.main.async { [weak self] in
                        self?.playerStatusView.isHidden = true
                    }
                }
                else{
                    DispatchQueue.main.async { [weak self] in
                        self?.playerStatusView.isHidden = false
                    }
                }
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




