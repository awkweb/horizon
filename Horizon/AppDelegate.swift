// By Tom Meagher on 1/20/21 at 22:07

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    @StateObject var store = AppStore()

    var statusBarItem: NSStatusItem!
    var menu = NSMenu()
    var window: NSPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = "❇️"
        statusBarItem?.button?.action = #selector(AppDelegate.statusBarButtonClicked(_:))
        statusBarItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        menu = NSMenu(title: "Status Bar Menu")
        menu.delegate = self
        menu.addItem(
            withTitle: "Preferences...",
            action: #selector(AppDelegate.viewPreferences),
            keyEquivalent: ",")
        menu.addItem(
            withTitle: "Open Horizon",
            action: #selector(AppDelegate.open),
            keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            withTitle: "Quit Horizon",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q")

        window = HorizonWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                               styleMask: [.borderless],
                               backing: .buffered,
                               defer: false)
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type ==  NSEvent.EventType.rightMouseUp {
            print("right")
            statusBarItem?.menu = menu
            statusBarItem?.button?.performClick(nil)
        } else {
            print("left")
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc func viewPreferences() {
        print("viewPreferences")
    }

    @objc func open() {
        window.makeKeyAndOrderFront(nil)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
