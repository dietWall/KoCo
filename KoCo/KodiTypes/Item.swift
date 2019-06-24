//
//  Item.swift
//  KoCo
//
//  Created by admin on 12.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


struct CurrentItemRequest: Codable{
    let properties      : [ListFieldsAll]
    let playerid        : Int
}

struct CurrentItemResponse: Codable{
    let album : String?
    let albumartist : [String]?
    let albumartistid : [Int]?
    let albumid : Int?
    let albumlabel : String?
    let albumreleasetype: String?
    let cast :VideoCast?
    let comment : String?
    let compilation : Bool?
    let contributors : ArtistContributors?
    let country :[String]?
    let description : String?
    let disc : Int?
    let displaycomposer : String?
    let displayconductor : String?
    let displaylyricist : String?
    let displayorchestra : String?
    let duration : Int?
    let episode  : Int?
    let episodeguide : String?
    let firstaired : String?
    let id : Library_Id?
    let imdbnumber : String?
    let lyrics : String?
    let mood :[ String]?
    let mpaa : String?
    let musicbrainzartistid : String?
    let musicbrainztrackid : String?
    let originaltitle : String?
    let plotoutline : String?
    let premiered : String?
    let productioncode : String?
    let releasetype : ReleaseType?
    let season  : Int?
    let set : String?
    let setid : Library_Id?
    let showlink :[ String]?
    let showtitle : String?
    let sorttitle : String?
    let specialsortepisode : Int?
    let specialsortseason  : Int?
    let studio :[ String]?
    let style :[ String]?
    let tag :[ String]?
    let tagline : String?
    let theme :[ String]?
    let top250 : Int?
    let track : Int?
    let trailer : String?
    let tvshowid : Library_Id?
    let type: String?
    let uniqueid :Int?             //this one is an object, but not clearly defined!!!
    let votes : String?
    let watchedepisodes : Int?
    let writer :[ String]?
}

struct ItemResult: Codable{
    let item: CurrentItemResponse
}


struct AudioDetailsMedia: Codable{
    let artist                          :[String]
    let artistid                        :[Int]
    let displayartist                   :String
    let genreid                         :[Int]
    let musicbrainzalbumartistid        :String
    let musicbrainzalbumid              :String
    let rating                          :Double
    let title                           :String
    let userrating                      :Int
    let votes                           :Int
    let year                            :Int
}


struct AudioItem :Codable, Equatable{
    let album                           :String?
    let albumartist                     :[String]?
    let artist                          :[String]?
    let displayartist                   :String?
    let fanart                          :String?
    let id                              :Int?
    let label                           :String?
    let thumbnail                       :String?
    let title                           :String?
    let track                           :Int?
    let type                            :String?
    
    
    func getFormated() -> String{
        var result = String()
        
        //result.append(label ?? "" + "\n")
        if title != nil{
            result.append(title! + "\n")
        }
        
        if albumartist != nil{
            result.append(albumartist![0] + "\n")
        }
        else if artist != nil{
            result.append(artist![0] + "\n")
        }
        else{
            result.append("\n")
        }
        
        result.append(album ?? "" + "\n")
        return result
    }    
}

struct AudioItemReturn: Codable{
    let item: AudioItem
}




struct PlayerPosition: Codable{
    let percentage: Float
    let time: GlobalTime
    let totaltime: GlobalTime
}


struct SeekRequest: Codable{
    let playerid : Int
    let value: Float?
}


