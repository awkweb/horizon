// By Tom Meagher on 1/21/21 at 23:39

import SwiftUI
import Preferences

/**
Function wrapping SwiftUI into `PreferencePane`, which is mimicking view controller's default construction syntax.
*/
let AccountPreferenceViewController: () -> PreferencePane = {
    /// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
    let paneView = Preferences.Pane(
        identifier: .account,
        title: "Account",
        toolbarIcon: NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: "Account preferences")!
    ) {
        AccountPreferencesView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

/**
The main view of “Account” preference pane.
*/
struct AccountPreferencesView: View {
    private let contentWidth: Double = 400.0

    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Futureland Login:") {
                Text("Futureland Login").preferenceDescription()
            }
        }
    }
}

struct AccountPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        AccountPreferencesView()
    }
}
