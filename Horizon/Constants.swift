// By Tom Meagher on 1/26/21 at 21:38

import KeyboardShortcuts
import Preferences
import SwiftUI
import UniformTypeIdentifiers

struct Constants {
    static let allowedContentTypes: [UTType] = [.image, .audiovisualContent]
    static let menuBarIcon = NSImage(named: "MenuBarIcon")!
}

enum Notifications {
    enum Actions {
        static let viewPublishedEntry = "VIEW_PUBLISHED_ENTRY_ACTION"
    }
    
    enum Categories {
        static let publishedEntry = "PUBLISHED_ENTRY"
    }
}

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel", default: .init(.d, modifiers: [.command]))
}

extension Preferences.PaneIdentifier {
    static let account = Self("account")
    static let general = Self("general")
}

extension Preferences {
    static let contentWidth: Double = 400.0
}
