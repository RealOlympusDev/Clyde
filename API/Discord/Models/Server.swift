import Foundation

public struct Server: Codable {
    var icon: String?
    var id: String?
    var name: String?
    var owner: Bool?
    var permissions: Int?
    var roles: [Role]?
    var emojis: [Emoji]?
    
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


