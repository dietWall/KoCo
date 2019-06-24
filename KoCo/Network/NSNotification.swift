//
//  Notification.swift
//  KoCo
//
//  Created by dietWall on 19.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let playlistRefresh = Notification.Name("playlistRefresh")
    static let propertiesRefresh = Notification.Name("propertiesRefresh")
    static let playerRefresh = Notification.Name("playerRefresh")
    static let itemChanged = Notification.Name("itemChanged")
    static let connectionStatusChanged = Notification.Name("connection")
    static let statusRefreshedNotificaten = Notification.Name("statusRefreshed")
}
