// By Tom Meagher on 1/14/21 at 09:45

import Foundation

struct AuthUser: Codable {
    var token: String
    var user: User

    enum CodingKeys: String, CodingKey {
        case token
        case user
    }
}
