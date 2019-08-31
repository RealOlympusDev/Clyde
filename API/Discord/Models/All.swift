//
//  All.swift
//  Discord
//
//  Created by Reuben on 27/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import Foundation

public struct All: Codable {
    
    init(servers: [Server], channels: [Channel], messages: [Message]) {
        self.servers = servers
        self.channels = channels
        self.messages = messages
    }

    var servers: [Server]
    var channels: [Channel]
    var all_channels: [Channel]?
    var messages: [Message]
    
}
