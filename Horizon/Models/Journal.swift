// By Tom Meagher on 1/23/21 at 14:23

import Foundation

struct Journal: Codable, Identifiable, Equatable {
    var id: Int
    var entryTemplate: String?
    var entryTemplateActive: Bool
    var isPrivate: Bool
    var lastEntryAt: Date?
    var slug: String
    var title: String

    enum CodingKeys: String, CodingKey {
        case id
        case entryTemplate
        case entryTemplateActive
        case isPrivate = "private"
        case lastEntryAt = "last_entry_at"
        case slug
        case title
    }
}
