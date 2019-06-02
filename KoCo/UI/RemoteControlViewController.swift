
//
//  RemoteControlViewController.swift
//  KoCo
//
//  Created by dietWall on 30.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


protocol KodiPlayerViewController{
    
    var player : KodiPlayer? {get set}
}



class RemoteControlViewController: UIViewController, KodiPlayerViewController {
    
    enum NavigationButtonTags : Int{
        case Up
        case Right
        case Down
        case Left
        case Enter
        case Back
    }
    
    var player : KodiPlayer? = nil
    
    //Timer for activePlayerStatus
    var timer : Timer?
    
    @IBOutlet weak var playerStatusView: UIView!
    
    @IBAction func directionKeyPressed(_ sender: UIButton) {
        
        switch(sender.tag)
        {
        case NavigationButtonTags.Up.rawValue:
            player?.navigate(to: .Up)
        case NavigationButtonTags.Down.rawValue:
            player?.navigate(to: .Down)
        case NavigationButtonTags.Left.rawValue:
            player?.navigate(to: .Left)
        case NavigationButtonTags.Right.rawValue:
            player?.navigate(to: .Right)
        case NavigationButtonTags.Enter.rawValue:
            player?.navigate(to: .Enter)
        case NavigationButtonTags.Back.rawValue:
            player?.navigate(to: .Back)
        default:
            print("unknown button title : \(String(describing: sender.tag))")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(refreshPlayerStatus)), userInfo: nil, repeats: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(player != nil){
            print("RemoteControlViewController" + (player?.name)!)
        }
        else
        {
            print("RemoteControlViewController " + "player not set" )
        }
        // Do any additional setup after loading the view.
        
        self.refreshPlayerStatus()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Timer must be invalidated, otherwise it will keep us in memory
        self.timer?.invalidate()
    }
    

    @objc func refreshPlayerStatus(){
        
        print("Refresh: \(String(describing: player?.name))")
        
        player?.getPlayerStatus(completion: { players, response, error in
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
                
                guard let response = response else{
                    let connectionFailedNotification = Notification(title: "Internal Error", alertStyle: .alert, message: "Error:" + error.debugDescription, actions: [NotificationButton(text: "Ok", style: .default)] )
                    self.createNotification(notification: connectionFailedNotification)
                    return
                }
                
                let connectionFailedNotification = Notification(title: "Connection failed", alertStyle: .alert, message: "Statuscode:" + String(response.statusCode), actions: [NotificationButton(text: "Ok", style: .default)] )
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




