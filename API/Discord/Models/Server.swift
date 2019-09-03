import Foundation

public struct Server: Codable {
    var premium_subscription_count: Int?
    var icon: String?
    var id: String?
    var name: String?
    var owner: Bool?
    var permissions: Int?
    var roles: [Role]?
    var emojis: [Emoji]?
    var splash: String?
    var owner_id: String?
    var region: String?
    var afk_channel_id: String?
    var afk_timeout: Int?
    var embed_enabled: Bool?
    var embed_channel_id: String?
    var verification_level: Int?
    var default_message_notifications: Int?
    var explicit_content_filter: Int?
    var features: [String]?
    var mfa_level: Int?
    var application_id: String?
    var widget_enabled: Bool?
    var widget_channel_id: String?
    var system_channel_id: String?
    var joined_at: String?
    var large: Bool?
    var unavailable: Bool?
    var member_count: Int?
    var voice_states: [VoiceState]?
    var members: [ServerMember]?
    var channels: [Channel]?
    var presences: [Presence?]?
    var max_presences: Int?
    var max_members: Int?
    var vanity_url_code: String?
    var description: String?
    var banner: String?
    var premium_tier: Int?
    var preferred_locale: String?
 
    func getRole(id: String) -> Role {
        return roles?.first(where: {$0.id == id}) ?? Role()
    }

}

public struct ServerMember: Codable {
    var user: User?
    var nick: String?
    var roles: [String?]?
    var joined_at: String?
    var premium_since: String?
    var deaf: Bool?
    var mute: Bool?
}

public struct Role: Codable{
    var id: String?
    var name: String?
    var color: Int?
    var hoist: Bool?
    var position: Int?
    var permissions: Int?
    var managed: Bool?
    var mentionable: Bool?
}

public struct Emoji: Codable{
    var id: String
    var name: String
    var roles: [Role]?
    var user: User?
    var require_colons: Bool?
    var managed: Bool?
    var animated: Bool?
}

public struct Presence: Codable{
    var user: User?
    var roles: [Role?]?
    var game: Activity?
    var guild_id: String?
    var status: String?
    var activities: [Activity?]?
    var client_status: ClientStatus?
    
}

public struct VoiceState: Codable {
    var guild_id: String?
    var channel_id: String?
    var user_id: String?
    var member: ServerMember?
    var session_id: String?
    var deaf: Bool?
    var mute: Bool?
    var self_deaf: Bool?
    var self_mute: Bool?
    var suppress: Bool?
}

public struct Activity: Codable{
    var name: String?
    var type: Int?
    var url: String?
    var timestamps: Timestamps?
    var application_id: String?
    var details: String?
    var state: String?
    var party: Party?
    var assets: Assets?
    var secrets: Secrets?
    var instance: Bool?
    var flags: Int?
}

public struct Timestamps: Codable{
    var start: Int64?
    var end: Int64?
}

public struct Party: Codable{
    var id: String?
    var size: [Int]?
}

public struct Assets: Codable{
    var large_image: String?
    var large_text: String?
    var small_image: String?
    var small_text: String?
}

public struct Secrets: Codable{
    var join: String?
    var spectate: String?
    var match: String?
}

public struct ClientStatus: Codable{
    var desktop: String?
    var mobile: String?
    var web: String?
}


