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
    
    init(content: String?) {
        self.content = content
    }
    
    var id: String?
    var channel_id: String?
    var guild_id: String?
    var author: User?
    var member: ServerMember?
    var content: String?
    var timestamp: String?
    var edited_timestamp: String?
    var tts: Bool?
    var mention_everyone: Bool?
    var mentions: [User?]?
    var mention_roles: [String?]?
    var mention_channels: [String?]?
    var attachments: [Attachment?]?
    var embeds: [Embeds?]?
    var reactions: [Reaction]?
    var nonce: String?
    var pinned: Bool?
    var webhook_id: String?
    var type: Int?
    var activity: [MessageActivity]?
    var application: [MessageApplication]?
    var message_reference: [MessageReference]?
    var flags: [Int]?
    
    var code: Int?
    var message: String?
    
    
    var server: Server?
    var channel: Channel?
    
    mutating func addServerAndChannel(server: Server, channel: Channel){
        self.server = server
        self.channel = channel
    }
    
}

public struct MessageActivity: Codable {
    var type: Int?
    var party_id: String?
}

public struct MessageApplication: Codable {
    var id: String?
    var cover_image: String?
    var description: String?
    var icon: String?
    var name: String?
}

public struct MessageReference: Codable {
    var message_id: String?
    var channel_id: String?
    var guild_id: String?
}

public struct Reaction: Codable {
    var count: Int?
    var me: Bool?
    var emoji: Emoji?
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



