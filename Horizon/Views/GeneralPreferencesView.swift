// By Tom Meagher on 1/21/21 at 23:27

import SwiftUI
import Preferences
import KeyboardShortcuts
import LaunchAtLogin

/**
Function wrapping SwiftUI into `PreferencePane`, which is mimicking view controller's default construction syntax.
*/
let GeneralPreferenceViewController: () -> PreferencePane = {
    /// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!
    ) {
        GeneralPreferencesView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

/**
The main view of “General” preference pane.
*/
struct GeneralPreferencesView: View {
    private let contentWidth: Double = 400.0

    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Startup:") {
                LaunchAtLogin.Toggle {
                    Text("Launch at login")
                }
            }

            Preferences.Section(title: "Keyboard Shortcuts:") {
                VStack {
                    HStack {
                        Text("New entry")
                        Spacer()
                    }
                    HStack {
                        KeyboardShortcuts.Recorder(for: .toggleNewEntry)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct GeneralPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPreferencesView()
    }
}
