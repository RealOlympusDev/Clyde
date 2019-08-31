//
//  Message.swift
//  Discord
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import Foundation

import Foundation

public struct Message: Codable {
    
    init(context: String?) {
        self.content = context
    }
    
    var attachments: [Attachment?]?
    var tts: Bool?
    var embeds: [Embeds?]?
    var timestamp: String?
    var mention_everyone: Bool?
    var id: String?
    var pinned: Bool?
    var edited_timestamp: String?
    var author: User?
    var mention_roles: [String?]?
    var content: String?
    var channel_id: String?
    var mentions: [User?]?
    var type: Int?
    var code: Int?
    var message: String?
    
    var member: ServerMember?
    
    var server: Server?
    var channel: Channel?
    
    mutating func addServerAndChannel(server: Server, channel: Channel){
        self.server = server
        self.channel = channel
    }
    
}

public struct Attachment: Codable {
    var url: String?
    var proxy_url: String?
    var filename: String?
    var width: Int?
    var height: Int?
    var id: String?
    var size: Int?
}

public struct Embeds: Codable {
    var description: String?
    var title: String?
    var url: String?
    var footer: Footer?
    var color: Int?
    var provider: Provider?
    var timestamp: String?
    var author: User?
    var type: String?
    var thumbnail: Attachment?
}

public struct Footer: Codable {
    var text: String?
}

public struct Provider: Codable {
    var url: String?
    var name: String?
}



