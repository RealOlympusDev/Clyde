//
//  Channel.swift
//  Discord
//
//  Created by Reuben on 25/05/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import Foundation

public struct Channel: Codable {
    var guild_id: String?
    var permission_overwrites: [Permission?]?
    var name: String?
    var parent_id: String?
    var nsfw: Bool?
    var position: Int?
    var bitrate: Int?
    var user_limit: Int?
    var rate_limit_per_user: Int?
    var last_message_id: String?
    var type: Int?
    var id: String?
    var recipients: [User]?
    var icon: String?
    
    var server: Server?
    
    mutating func addServer(server: Server){
        self.server = server
    }

}

public struct Permission: Codable {
    var deny: Int?
    var type: String?
    var id: String?
    var allow: Int?
}

public struct PermissionType: Codable {
    
    static var CREATE_INSTANT_INVITE = 0x1
    static var KICK_MEMBERS = 0x2
    static var BAN_MEMBERS = 0x4
    static var ADMINISTRATOR = 0x8
    static var MANAGE_CHANNELS = 0x10
    static var MANAGE_GUILD = 0x20
    static var ADD_REACTIONS = 0x40
    static var VIEW_AUDIT_LOG = 0x80
    static var VIEW_CHANNEL = 0x400
    static var SEND_MESSAGES = 0x800
    static var SEND_TTS_MESSAGES = 0x1000
    static var MANAGE_MESSAGES = 0x2000
    static var EMBED_LINKS = 0x4000
    static var ATTACH_FILES = 0x8000
    static var READ_MESSAGE_HISTORY = 0x10000
    static var MENTION_EVERYONE = 0x20000
    static var USE_EXTERNAL_EMOJIS = 0x40000
    static var CONNECT = 0x100000
    static var SPEAK = 0x400000
    static var MUTE_MEMBERS = 0x400000
    static var DEAFEN_MEMBERS = 0x800000
    static var MOVE_MEMBERS = 0x1000000
    static var USE_VAD = 0x2000000
    static var PRIORITY_SPEAKER = 0x100
    static var STREAM = 0x200
    static var CHANGE_NICKNAME = 0x4000000
    static var MANAGE_NICKNAMES = 0x8000000
    static var MANAGE_ROLES = 0x10000000
    static var MANAGE_WEBHOOKS = 0x20000000
    static var MANAGE_EMOJIS = 0x40000000
    static var ALL = CREATE_INSTANT_INVITE  | KICK_MEMBERS  | BAN_MEMBERS  | ADMINISTRATOR  | MANAGE_CHANNELS  | MANAGE_GUILD  | ADD_REACTIONS  | VIEW_AUDIT_LOG  | VIEW_CHANNEL  | SEND_MESSAGES  | SEND_TTS_MESSAGES  | MANAGE_MESSAGES  | EMBED_LINKS  | ATTACH_FILES  | READ_MESSAGE_HISTORY  | MENTION_EVERYONE | USE_EXTERNAL_EMOJIS | CONNECT | SPEAK | MUTE_MEMBERS | DEAFEN_MEMBERS | MOVE_MEMBERS | USE_VAD | PRIORITY_SPEAKER | STREAM | CHANGE_NICKNAME | MANAGE_NICKNAMES | MANAGE_ROLES | MANAGE_WEBHOOKS | MANAGE_EMOJIS
    static var NONE = 0x0
    
}

var permissions = [
    
                   "CREATE_INSTANT_INVITE" : 0x1,
                   "KICK_MEMBERS" : 0x2,
                   "BAN_MEMBERS": 0x4,
                   "ADMINISTRATOR": 0x8,
                   "MANAGE_CHANNELS": 0x10,
                   "MANAGE_GUILD": 0x20,
                   "ADD_REACTIONS": 0x40,
                   "VIEW_AUDIT_LOG" : 0x80,
                   "VIEW_CHANNEL" : 0x400,
                   "SEND_MESSAGES" : 0x800,
                   "SEND_TTS_MESSAGES" : 0x1000,
                   "MANAGE_MESSAGES" : 0x2000,
                   "EMBED_LINKS": 0x4000,
                   "ATTACH_FILES": 0x8000,
                   "READ_MESSAGE_HISTORY": 0x10000,
                   "MENTION_EVERYONE": 0x20000,
                   "USE_EXTERNAL_EMOJIS": 0x40000,
                   "CONNECT": 0x100000,
                   "SPEAK": 0x400000,
                   "MUTE_MEMBERS": 0x400000,
                   "DEAFEN_MEMBERS": 0x800000,
                   "MOVE_MEMBERS": 0x1000000,
                   "USE_VAD": 0x2000000,
                   "PRIORITY_SPEAKER": 0x100,
                   "STREAM": 0x200,
                   "CHANGE_NICKNAME": 0x4000000,
                   "MANAGE_NICKNAMES": 0x8000000,
                   "MANAGE_ROLES": 0x10000000,
                   "MANAGE_WEBHOOKS": 0x20000000,
                   "MANAGE_EMOJIS": 0x40000000
    
]
