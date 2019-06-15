//
//  ActivePlayer.swift
//  KoCo
//
//  Created by admin on 11.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation



struct ActivePlayer : Codable{
    var playerid : Int
    var type : String
}

struct VolumeParams : Codable{
    let volume : Int
}


enum PlayerProperties: String, Codable{
    case audiostreams
    case canchangespeed
    case canmove
    case canrepeat
    case canrotate
    case canseek
    case canshuffle
    case canzoom
    case currentaudiostream
    case currentsubtitle
    case currentvideostream
    case live
    case partymode
    case percentage
    case playlistid
    case position
    case repeated = "repeat"            //repeat is keyword in swift
    case shuffled
    case speed
    case subtitleenabled
    case subtitles
    case time
    case totaltime
    case type
    case videostreams
}


struct CurrentProperties : Codable{
    let canchangespeed : Bool?
    let canmove : Bool?
    let canrepeat : Bool?
    let canrotate : Bool?
    let canseek : Bool?
    let canshuffle : Bool?
    let canzoom : Bool?
    let live : Bool?
    let partymode : Bool?
    let percentage : Float?
    let playlistid : Int?
    let position  : Int?
    let repeated : RepeatMode?
    let shuffled : Bool?
    let speed : Int?
    let subtitleenabled : Bool?
    let time : GlobalTime?
    let totaltime :GlobalTime?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case repeated = "repeat"                //repeat is a keyword in Swift
        
        case canchangespeed
        case canmove
        case canrepeat
        case canrotate
        case canseek
        case canshuffle
        case canzoom
        case live
        case partymode
        case percentage
        case playlistid
        case position
        case shuffled
        case speed
        case subtitleenabled
        case time
        case totaltime
        case type
    }
}

enum RepeatMode : String, Codable{
    case off
    case one
    case all
}

struct PlayerPropertiesRequest : Codable{
    let playerid : Int
    let properties: [PlayerProperties]
}


struct SetRepeatParams : Codable{
    let playerid : Int
    let repeatMode : RepeatMode
    
    enum CodingKeys: String, CodingKey {
        case repeatMode = "repeat"                //repeat is a keyword in Swift
        case playerid
    }
}

struct SetShuffleParams : Codable{
    let playerid : Int
    let shuffle : Bool
}
