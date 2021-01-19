// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI

@main
struct HorizonApp: App {
    @StateObject var store = AppStore()

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover.behavior = .transient // !!! - This does not seem to work in SwiftUI2.0 or macOS BigSur yet
        popover.animates = false
        popover.contentViewController = NSViewController()
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = "Horizon"
        statusBarItem?.button?.action = #selector(AppDelegate.togglePopover(_:))
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusBarItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
}
