//
//  GlobalTime.swift
//  KoCo
//
//  Created by admin on 15.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


struct GlobalTime: Codable{
    let hours: Int
    let milliseconds: Int
    let minutes: Int
    let seconds: Int
    
    
    func getFormatted() -> String{
        
        var result = String()
        
        //hours: optional, don´t print if 0
        if(self.hours != 0)
        {
            result.append(String(hours))
            result.append(":")
        }
        
        //Minutes: always print them out, even if 0
        result.append(String(format: "%02d", minutes))
        result.append(":")
        
        //Seconds: also always
        result.append(String(format: "%02d", seconds))
        
        //milliseconds are don´t care
        
        return result
    }
    
}
