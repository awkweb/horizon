// By Tom Meagher on 1/18/21 at 13:12

import Foundation

struct Entry: Codable, Identifiable {
    var id: Int
    var journalId: Int
    var notes: String

    enum CodingKeys: String, CodingKey {
        case id
        case journalId = "journal_id"
        case notes
    }
}
