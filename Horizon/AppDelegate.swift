// By Tom Meagher on 1/20/21 at 22:07

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var menu = NSMenu()
    var window: NSPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = "❇️"
        statusBarItem?.button?.action = #selector(AppDelegate.statusBarButtonClicked(_:))
        statusBarItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        menu = HorizonMenu()
        window = HorizonWindow()
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type ==  NSEvent.EventType.rightMouseUp {
            print("right")
            statusBarItem?.menu = menu
            statusBarItem?.button?.performClick(nil)
        } else {
            print("left")
            if window.isKeyWindow {
                window.close()
            } else {
                window.makeKeyAndOrderFront(nil)
            }
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
