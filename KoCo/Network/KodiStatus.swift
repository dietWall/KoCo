//
//  KodiStatus.swift
//  KoCo
//
//  Created by admin on 18.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

class KodiStatus{
    var kodiPlayer: KodiPlayer
    
    var timer : Timer?
    
    var notConnected = false
    
    var activePlayer : [ActivePlayer]?
    
    init(player: KodiPlayer){
        self.kodiPlayer = player
        //
        refreshStatus()
    }
    
    @objc func refreshStatus(){
        Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(refreshStatus)), userInfo: nil, repeats: true)

        refreshActivePlayers()
        
        //get Properties for Audio Players
        //refreshProperties()
        
    }
    
    
    private func refreshActivePlayers(){
        kodiPlayer.getPlayerStatus(completion: {
            result, response, error in

            guard let result = result else{
                self.notConnected = true
                return
            }
            
            //Prevent Modell from changing if nothing new happened
            self.activePlayer = result
        })
    }
}
