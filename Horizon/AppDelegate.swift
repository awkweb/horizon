// By Tom Meagher on 1/23/21 at 12:12

import Cocoa
import KeyboardShortcuts
import Preferences
import SwiftUI

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

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension NSApplication {
    func quit() {
        NSApp.terminate(nil)
    }
}

/**
Convenience function for initializing an object and modifying its properties.
```
let label = with(NSTextField()) {
    $0.stringValue = "Foo"
    $0.textColor = .systemBlue
    view.addSubview($0)
}
```
*/
@discardableResult
func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
    var this = item
    try update(&this)
    return this
}

class Store: ObservableObject {
    @Published
    var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "Token")
        }
    }
    
    @AppStorage("Username")
    var username: String?
    
    init() {
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            return
        }
        self.token = token
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var store = Store()
    
    lazy var panel = PublishPanel(
        store: store,
        onClose: closePanel
    )
    
    /// Set up preferences
    lazy var preferences: [PreferencePane] = [
        GeneralPrefsViewController(store),
        AccountPrefsViewController(store),
    ]
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: preferences,
        style: .segmentedControl,
        animated: false,
        hidesToolbarForSingleItem: true
    )
    
    /// Set up menu bar
    lazy var menu = StatusBarMenu(
        openPrefs: self.openPrefs,
        openPanel: self.openPanel,
        quit: self.quit
    )
    lazy var statusBarItem = with(NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)) {
        $0.menu = menu
        $0.button?.title = "❇️"
    }
    lazy var statusBarItemButton = statusBarItem.button

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = statusBarItemButton
        
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [self] in togglePanel() }
        
        if store.token == nil {
            preferencesWindowController.show(preferencePane: .account)
        }
    }
}

extension AppDelegate {
    private func togglePanel() {
        if panel.isKeyWindow {
            closePanel()
        } else {
            openPanel()
        }
    }
    
    private func closePanel() {
        panel.close()
    }

    private func openPanel() {
        guard store.token != nil else {
            preferencesWindowController.show(preferencePane: .account)
            return
        }
        panel.makeKeyAndOrderFront(nil)
    }
    
    private func openPrefs() {
        preferencesWindowController.show()
    }
    
    private func quit() {
        NSApp.quit()
    }
}
