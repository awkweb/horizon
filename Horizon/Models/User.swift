// By Tom Meagher on 1/23/21 at 14:16

import Foundation

struct User: Codable, Identifiable {
    var id: Int
    var username: String

    enum CodingKeys: String, CodingKey {
        case id
        case username = "futureland_user"
    }
}
