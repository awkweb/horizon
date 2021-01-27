// By Tom Meagher on 1/27/21 at 09:47

// From https://github.com/coteditor/CotEditor/blob/master/CotEditor/Sources/UpdaterManager.swift

import Cocoa
import Sparkle

private enum AppCastURL {
    case stable
    case beta
    
    static let host = "https://raw.githubusercontent.com/tmm/horizon/blob/main/.sparkle/"
    
    /// URL for app cast
    var URL: String {
        return AppCastURL.host + self.filename
    }
    
    /// filename of app cast
    private var filename: String {
        
        switch self {
        case .stable:
            return "appcast.xml"
        case .beta:
            return "appcast-beta.xml"
        }
    }
}

final class UpdaterManager: NSObject, SUUpdaterDelegate {
    static let shared = UpdaterManager()
        
    // MARK: Lifecycle
    private override init() {
        super.init()
    }
    
    deinit {
        SUUpdater.shared().delegate = nil
    }
    
    // MARK: Public Methods
    /// setup Sparkle
    func setup(menu: StatusBarMenu) {
        
        guard let updater = SUUpdater.shared() else { return }
        
        // set delegate
        updater.delegate = self
        
        // insert "Check for Updates…" menu item
        let menuItem = NSMenuItem(
            title: NSLocalizedString("Check for updates", comment: ""),
            action: #selector(SUUpdater.checkForUpdates),
            keyEquivalent: ""
        )
        menuItem.target = updater
        menu.insertItem(menuItem, at: 2)
        
        // lock update check interval to daily
        updater.updateCheckInterval = TimeInterval(60 * 60 * 24)
    }
    
    // MARK: Sparkle Updater Delegate

    /// return AppCast file URL dynamically
    func feedURLString(for updater: SUUpdater) -> String? {
        let appCast: AppCastURL = .stable
        print(appCast.URL)
        return appCast.URL
    }
}
