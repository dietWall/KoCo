//
//  List.swift
//  KoCo
//
//  Created by dietWall on 06.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

enum Order : String, Codable{
    case ascending
    case descending
    
}

struct SortType : Codable{
    let order : Order
    let method: String
    let ignorearticle : Bool
    
}

struct ListLimits : Codable{
    let start   : Int
    let end     : Int
    let total   : Int?
}

enum ListFiedsAll : String, Codable{
    case title
    case artist
    case albumartist
    case genre
    case year
    case rating
    case album
    case track
    case duration
    case comment
    case lyrics
    case musicbrainztrackid
    case musicbrainzartistid
    case musicbrainzalbumid
    case musicbrainzalbumartistid
    case playcount
    case fanart
    case director
    case trailer
    case tagline
    case plot
    case plotoutline
    case originaltitle
    case lastplayed
    case writer
    case studio
    case mpaa
    case cast
    case country
    case imdbnumber
    case premiered
    case productioncode
    case runtime
    case set
    case showlink
    case streamdetails
    case top250
    case votes
    case firstaired
    case season
    case episode
    case showtitle
    case thumbnail
    case file
    case resume
    case artistid
    case albumid
    case tvshowid
    case setid
    case watchedepisodes
    case disc
    case tag
    case art
    case genreid
    case displayartist
    case albumartistid
    case description
    case theme
    case mood
    case style
    case albumlabel
    case sorttitle
    case episodeguide
    case uniqueid
    case dateadded
    case channel
    case channeltype
    case hidden
    case locked
    case channelnumber
    case starttime
    case endtime
    case specialsortseason
    case specialsortepisode
    case compilation
    case releasetype
    case albumreleasetype
    case contributors
    case displaycomposer
    case displayconductor
    case displayorchestra
    case displaylyricist
    case userrating
}
