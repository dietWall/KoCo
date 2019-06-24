//
//  Playlist.swift
//  KoCo
//
//  Created by dietWall on 15.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


typealias PlaylistId = Int


struct PlaylistGetItemsParams : Codable{
    let playlistid  : PlaylistId
    let properties  : [ListFieldsAll]
    let limits      : ListLimits
    let sort        : ListSort
}

struct PlaylistGetItemsResponse : Codable{
    let items       : [AudioItem]
    let limits      : ListLimitsReturned
}


struct PlaylistRemoveItemParams : Codable{
    let playlistid: PlaylistId
    let position : Int
}

struct PlaylistRemoveItemResponse : Codable{
    let result: String
}


struct AddArtistId :  Codable{
    let artistid : LibraryId
}

struct AddAlbumId : Codable{
    let albumid : LibraryId
}

struct AddSongId : Codable{
    let songid : LibraryId
}

struct PlaylistAddItemsParams<ItemType : Codable> : Codable{
    let playlistid : PlaylistId
    let item       : ItemType
}


struct PlayList: Codable{
    let playlistid: PlaylistId
    let type: String
}

struct PlaylistAddItemsResponse : Codable{
    let result: String
}

struct PlaylistClearParams: Codable{
    let playlistid      : PlaylistId
}

