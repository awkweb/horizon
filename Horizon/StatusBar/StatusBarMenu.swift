// By Tom Meagher on 1/23/21 at 12:34

import Foundation
import SwiftUI

final class StatusBarMenu: NSMenu, NSMenuDelegate {
    init(
        openPanel: @escaping () -> Void,
        openPrefs: @escaping () -> Void,
        quit: @escaping () -> Void
    ) {
        super.init(title: "Status Bar Menu")
        delegate = self

        let openMenuItem = StatusBarMenuItem("Open Horizon") { _ in openPanel() }
        let preferencesMenuItem = StatusBarMenuItem("Preferences", key: ",") { _ in openPrefs() }
        let quitMenuItem = StatusBarMenuItem("Quite Horizon", key: "q") { _ in quit() }

        addItem(openMenuItem)
        addItem(preferencesMenuItem)
        addItem(NSMenuItem.separator())
        addItem(quitMenuItem)
    }

    required init(coder: NSCoder) {
        fatalError("Not yet implemented.")
    }
}
