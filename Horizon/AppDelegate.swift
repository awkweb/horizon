// By Tom Meagher on 1/23/21 at 12:12

import Cocoa
import Combine
import KeyboardShortcuts
import Preferences
import SwiftUI
import UserNotifications

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
    
    let isFirstLaunch: Bool = {
        let key = "HasLaunched"

        if UserDefaults.standard.bool(forKey: key) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
    }()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var store = Store()

    lazy var panel = PublishPanel(
        store: store,
        onClose: closePanel
    )

    /// Set up preferences
    lazy var preferences: [PreferencePane] = [
        GeneralPrefsViewController(store),
        AccountPrefsViewController(store)
    ]
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: preferences,
        style: .segmentedControl,
        animated: false,
        hidesToolbarForSingleItem: true
    )

    /// Set up menu bar
    lazy var menu = StatusBarMenu(
        openPanel: self.openPanel,
        openPrefs: self.openPrefs,
        quit: self.quit
    )
    lazy var statusBarItem = with(NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)) {
        $0.menu = menu
        $0.button?.image = Constants.menuBarIcon
        $0.button?.image?.size = NSSize(width: 18.0, height: 18.0)
        $0.button?.image?.isTemplate = true
    }
    lazy var statusBarItemButton = statusBarItem.button

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = statusBarItemButton
        _ = panel
        
        panel.makeKeyAndOrderFront(nil)

        if store.token == nil {
            preferencesWindowController.show(preferencePane: .account)
        }
        
        // Set up keyboard shortcuts
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [self] in togglePanel() }
        
        // Set up notifications
        UNUserNotificationCenter.current().delegate = self
        setupNotifications()
        
        // Set up Sparkle
        UpdaterManager.shared.setup(menu: menu)
    }
}

// MARK: Menu bar
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

// MARK: Notifications
extension AppDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let entryUrl = userInfo["entryUrl"] as! String
                
        switch response.actionIdentifier {
        case Notifications.Actions.viewPublishedEntry:
            if let url = URL(string: entryUrl) {
                NSWorkspace.shared.open(url)
            }
           break
        default:
           break
        }
        
        completionHandler()
    }
    
    private func setupNotifications() {
        // Define custom actions
        let acceptAction = UNNotificationAction(
            identifier: Notifications.Actions.viewPublishedEntry,
            title: "View",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        
        // Define notification type
        let publishedEntryCategory =
              UNNotificationCategory(
                identifier: Notifications.Categories.publishedEntry,
                actions: [acceptAction],
                intentIdentifiers: [],
                hiddenPreviewsBodyPlaceholder: ""
              )

        // Register notification type
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([publishedEntryCategory])
        
        guard store.isFirstLaunch else { return }
        
        // Request permissions
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert]) { success, error in
           if success {
               print("User Accepted")
           } else if let error = error {
               print(error.localizedDescription)
          }
        }
    }
}
