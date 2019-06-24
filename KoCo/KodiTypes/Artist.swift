//
//  Artist.swift
//  KoCo
//
//  Created by dietWall on 06.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

enum ArtistProperties :String, Codable{
    case instrument
    case style
    case mood
    case born
    case formed
    case description
    case genre
    case died
    case disbanded
    case yearsactive
    case musicbrainzartistid
    case fanart
    case thumbnail
    case compilationartist
    case dateadded
    case roles
    case songgenres
    case isalbumartist
}

struct ArtistsGetParams: Codable{
    let properties          : [ArtistProperties]
    let limits              : ListLimits
    let sort                : ListSort
}

struct AudioDetailsArtist : Codable{
    let artist                  : String?
    let artistid                : Int
    let born                    : String?
    let compilationartist       : Bool?
    let description             : String?
    let died                    : String?
    let disbanded               : String?
    let formed                  : String?
    let instrument              : [String]?
    let isalbumartist           : Bool?
    let mood                    : [String]?
    let musicbrainzartistid     : String?
    let roles                   : [String]?
    let songgenres              : [String]?
    let style                   : [String]?
    let yearsactive             : [String]?
}

struct ArtistGetResult : Codable{
    let artists : [AudioDetailsArtist]
    let limits : ListLimitsReturned
}


struct ArtistContributors: Codable{
    let artistid : LibraryId
    let name: String?
    let role: String?
    let roleid: LibraryId?
}
