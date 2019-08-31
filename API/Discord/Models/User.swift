//
//  User.swift
//  DiscordTest WatchKit Extension
//
//  Created by Reuben Catchpole on 30/06/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import Foundation

public struct User: Codable {
    var username: String?
    var discriminator: String?
    var bot: Bool?
    var id: String?
    var avatar: String?
}
