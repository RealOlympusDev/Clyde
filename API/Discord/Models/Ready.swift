//
//  Ready.swift
//  Clyde WatchKit Extension
//
//  Created by Reuben Catchpole on 31/08/19.
//  Copyright © 2019 Reuben Catchpole. All rights reserved.
//

import Foundation

public struct Ready: Codable {
    
    var v: Int?
    var guilds: [Server]?
    var user: User?
    var session_id: String?

}
