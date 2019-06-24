//
//  KodiFile.swift
//  KoCo
//
//  Created by dietWall on 13.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


struct FileDownloadParams : Codable{
    let path : String
}

struct FileDownloadResponse : Codable{
    let details : FileDownloadParams
    let mode : String?
    let _protocol : String?                 //protocol is a keyword in swift
    
    enum CodingKeys: String, CodingKey {
        case _protocol = "protocol"
        case details
        case mode
    }
}
