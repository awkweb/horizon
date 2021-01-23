// By Tom Meagher on 1/23/21 at 14:15

import Foundation

struct AuthUser: Codable {
    var token: String
    var user: User

    enum CodingKeys: String, CodingKey {
        case token
        case user
    }
}
