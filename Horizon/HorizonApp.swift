// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI

@main
struct HorizonApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            VStack {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    @StateObject var store = AppStore()

    var statusBarItem: NSStatusItem!
    var menu = NSMenu(title: "Status Bar Menu")
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = "🌅"
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
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type ==  NSEvent.EventType.rightMouseUp {
            statusBarItem?.menu = menu
            statusBarItem?.button?.performClick(nil)
        } else {
            openWindow()
        }
    }

    @objc func viewPreferences() {
        print("viewPreferences")
    }

    @objc func open() {
        openWindow()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    private func openWindow() {
        if window != nil { return }

        let rootView = RootView()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled],
            backing: .buffered,
            defer: false)
        window.center()
        window.titleVisibility = .hidden
        window.contentView = NSHostingView(rootView: rootView)
        window.makeKeyAndOrderFront(nil)
    }
}
