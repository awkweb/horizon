// By Tom Meagher on 1/20/21 at 22:07

import Foundation
import SwiftUI
import Preferences
import KeyboardShortcuts


class AppDelegate: NSObject, NSApplicationDelegate {
    let menu = HorizonMenu()
    
    lazy var statusItem = with(NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)) {
        $0.menu = menu
        $0.button?.title = "❇️"
//        $0.button?.image = Constants.menuBarIcon
    }
    lazy var statusItemButton = statusItem.button!
    lazy var window = HorizonWindow()

    lazy var preferences: [PreferencePane] = [
        GeneralPreferenceViewController(),
        AccountPreferenceViewController(),
    ]

    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: preferences,
        style: .segmentedControl,
        animated: true,
        hidesToolbarForSingleItem: true
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = statusItemButton
        _ = window
        KeyboardShortcuts.onKeyUp(for: .toggleNewEntry) { [self] in toggleWindow() }
    }
    
    private func toggleWindow() {
        if window.isKeyWindow {
            window.close()
        } else {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc func viewPreferences() {
        preferencesWindowController.show()
    }

    @objc func open() {
        window.makeKeyAndOrderFront(nil)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
