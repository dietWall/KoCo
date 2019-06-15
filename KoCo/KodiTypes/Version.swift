//
//  Version.swift
//  KoCo
//
//  Created by admin on 06.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

struct VersionObj : Codable {
    var version : Version
}

struct Version : Codable{
    var major : Int
    var minor : Int
    var patch : Int
}
