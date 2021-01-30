// By Tom Meagher on 1/23/21 at 12:12

import Cocoa
import Combine
import KeyboardShortcuts
import Preferences
import Sparkle
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
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, SUUpdaterDelegate {
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
        checkForUpdates: self.checkForUpdates,
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

        if store.token == nil {
            preferencesWindowController.show(preferencePane: .account)
        } else {
            panel.makeKeyAndOrderFront(nil)
        }
        
        // Set up keyboard shortcuts
        KeyboardShortcuts.onKeyUp(for: .togglePanel) { [self] in togglePanel() }
        
        // Set up notifications
        setupNotifications()
        
        // Set up Sparkle for auto updates
        setupSparkle()
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
        panel.close()
        preferencesWindowController.show()
    }

    private func quit() {
        NSApp.quit()
    }
}

// MARK: Notifications
extension AppDelegate {
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self

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
                
        // Request permissions
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert]) { success, error in
           if success {
               print("User accepted push notifications")
           } else if let error = error {
               print(error.localizedDescription)
          }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
                
        switch response.actionIdentifier {
        case Notifications.Actions.viewPublishedEntry:
            guard let entryUrl = userInfo["entryUrl"] as? String else {
                return
            }
            if let url = URL(string: entryUrl) {
                NSWorkspace.shared.open(url)
            }
        default:
           break
        }
        
        completionHandler()
    }
}

// MARK: Sparkle
extension AppDelegate {
    private func setupSparkle() {
        guard let updater = SUUpdater.shared() else { return }
        updater.delegate = self
        updater.updateCheckInterval = TimeInterval(60 * 60 * 24)
    }

    private func checkForUpdates() {
        panel.close()
        guard let updater = SUUpdater.shared() else { return }
        updater.checkForUpdates(self)
    }
    
    func feedURLString(for updater: SUUpdater) -> String? {
        return "https://dl.dropbox.com/s/e22wt50uqlg7pu1/appcast.xml"
    }
}
