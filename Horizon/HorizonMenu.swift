// By Tom Meagher on 1/21/21 at 09:41

import Foundation
import SwiftUI

class HorizonMenu: NSMenu, NSMenuDelegate {
    init() {
        super.init(title: "Status Bar Menu")
        delegate = self
        addItem(
            withTitle: "Preferences...",
            action: #selector(AppDelegate.viewPreferences),
            keyEquivalent: ",")
        addItem(
            withTitle: "Open Horizon",
            action: #selector(AppDelegate.open),
            keyEquivalent: "")
        addItem(NSMenuItem.separator())
        addItem(
            withTitle: "Quit Horizon",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
