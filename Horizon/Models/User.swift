// By Tom Meagher on 1/14/21 at 09:46

import Foundation

struct User: Codable, Identifiable {
    var avatar: String
    var id: Int
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case avatar = "avatar_link"
        case id
        case username = "futureland_user"
    }
}
