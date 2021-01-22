// By Tom Meagher on 1/22/21 at 09:31

import Foundation
import Preferences
import KeyboardShortcuts

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let account = Self("account")
}

extension KeyboardShortcuts.Name {
    static let toggleNewEntry = Self("toggleNewEntry", default: .init(.d, modifiers: [.command]))
}
