// By Tom Meagher on 1/23/21 at 12:21

import KeyboardShortcuts
import LaunchAtLogin
import Preferences
import SwiftUI

let GeneralPrefsViewController: (Store) -> PreferencePane = { store in
    let toolbarIcon = NSImage(
        systemSymbolName: "gearshape",
        accessibilityDescription: "General preferences"
    )
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: toolbarIcon!
    ) {
        GeneralPrefsView().environmentObject(store)
    }

    return Preferences.PaneHostingController(pane: paneView)
}

struct GeneralPrefsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        Preferences.Container(contentWidth: Preferences.contentWidth) {
            Preferences.Section(title: "Startup:") {
                LaunchAtLogin.Toggle {
                    Text("Launch at login")
                }
            }
            Preferences.Section(title: "Keyboard Shortcuts:") {
                VStack(alignment: .leading) {
                    Text("Toggle Horizon window")
                    KeyboardShortcuts.Recorder(for: .togglePanel)
                }
            }
        }
    }
}

struct GeneralPrefsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPrefsView()
    }
}
