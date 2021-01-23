// By Tom Meagher on 1/23/21 at 14:23

import Foundation

struct Journal: Codable, Identifiable {
    var id: Int
    var lastEntryAt: Date
    var title: String

    enum CodingKeys: String, CodingKey {
        case id
        case lastEntryAt = "last_entry_at"
        case title
    }
}
