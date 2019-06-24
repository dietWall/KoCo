//
//  Song.swift
//  KoCo
//
//  Created by dietWall on 19.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


enum SongProperties :String, Codable{
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
    case thumbnail
    case file
    case albumid
    case lastplayed
    case disc
    case genreid
    case artistid
    case displayartist
    case albumartistid
    case albumreleasetype
    case dateadded
    case votes
    case userrating
    case mood
    case contributors
    case displaycomposer
    case displayconductor
    case displayorchestra
    case displaylyricist
}

struct SongDetails : Codable{
    let title               : String?
    let album               : String?
    let albumartist         : [String]?
    let albumartistid       : [Int]?
    let albumid             : Library_Id?
    let albumreleasetype    : ReleaseType?
    let comment             : String?
    let contributors        : [ArtistContributors]?
    let disc                : Int?
    let displaycomposer     : String?
    let displayconductor    : String?
    let displaylyricist     : String?
    let displayorchestra    : String?
    let duration            : Int?
    let file                : String?
    let lastplayed          : String?
    let lyrics              : String?
    let mood                : String?
    let musicbrainzartistid : String?
    let musicbrainztrackid  : String?
    let playcount           : Int?
    let songid              : Library_Id?
    let track               : Int?
}

struct GetSongsParams: Codable{
    let properties: [SongProperties]
    let limits: ListLimits
    let sort: ListSort
}

struct GetSongsResult:Codable{
    let songs: [SongDetails]
    let limits: ListLimitsReturned
}


