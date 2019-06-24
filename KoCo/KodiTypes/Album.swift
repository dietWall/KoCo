//
//  Album.swift
//  KoCo
//
//  Created by admin on 12.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

enum ReleaseType :String, Codable{
    case album
    case single
}


enum AlbumProperties : String, Codable{
    case title
    case description
    case artist
    case genre
    case theme
    case mood
    case style
    case type
    case albumlabel
    case rating
    case votes
    case userrating
    case year
    case musicbrainzalbumid
    case musicbrainzalbumartistid
    case fanart
    case thumbnail
    case playcount
    case genreid
    case artistid
    case displayartist
    case compilation
    case releasetype
    case dateadded
}


struct RequestAlbumsParams: Codable{
    let properties      : [AlbumProperties]
    let limits          : ListLimits
    let sort            : ListSort
    let includesingles  : Bool?
    let allroles        : Bool?
}


struct AudioDetailsAlbum : Codable{
    let title : String?
    let description : String?
    let artist : [String]?
    let genre : [String]?
    let theme : [String]?
    let mood : [String]?
    let style : [String]?
    let type : String?
    let albumlabel : String?
    let rating : Float?
    let votes : Int?
    let userrating : Int?
    let year : Int?
    let musicbrainzalbumid : String?
    let musicbrainzalbumartistid : String?
    let thumbnail : String?
    let playcount : Int?
    let genreid  : [LibraryId]?
    let artistid : [LibraryId]?
    let displayartist : String?
    let compilation : Bool?
    let releasetype : ReleaseType?
    let dateadded : String?
    let albumid: Int
}

struct AlbumGetResponse : Codable{
    let albums : [AudioDetailsAlbum]
    let limits : ListLimitsReturned
}

