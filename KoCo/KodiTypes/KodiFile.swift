//
//  KodiFile.swift
//  KoCo
//
//  Created by admin on 13.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


struct FileDownloadRequest : Codable{
    let path : String
}

struct FileDownloadResponse : Codable{
    let details : FileDownloadRequest       //TODO: find a better name for this
    let mode : String?
    let _protocol : String?
    
    enum CodingKeys: String, CodingKey {
        case _protocol = "protocol"
        case details
        case mode
    }
}
