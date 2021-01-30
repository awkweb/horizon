// By Tom Meagher on 1/23/21 at 13:56

import SwiftUI
import Preferences

let AccountPrefsViewController: (Store) -> PreferencePane = { store in
    let toolbarIcon = NSImage(
        systemSymbolName: "person.crop.circle",
        accessibilityDescription: "Account preferences"
    )
    let paneView = Preferences.Pane(
        identifier: .account,
        title: "Account",
        toolbarIcon: toolbarIcon!
    ) {
        AccountPrefsView(
            viewModel: PrefsViewModel(store: store)
        ).environmentObject(store)
    }

    return Preferences.PaneHostingController(pane: paneView)
}

struct AccountPrefsView: View {
    @EnvironmentObject
    var store: Store

    @ObservedObject
    var viewModel: PrefsViewModel

    init(
        viewModel: PrefsViewModel
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if let username = viewModel.store.user?.username,
               viewModel.store.token != nil {
                VStack {
                    Text("Signed in as @\(username)")
                    Button("Log out", action: viewModel.logout)
                }
            } else {
                Form {
                    Text("Log in to Futureland")

                    TextField("Email", text: $viewModel.email)

                    SecureField("Password", text: $viewModel.password)

                    HStack {
                        Button("Login", action: viewModel.login)
                            .disabled(viewModel.networkActive)
                            .keyboardShortcut(.return, modifiers: [.command])

                        Spacer()

                        if let error = viewModel.error {
                            Text(error)
                        }
                    }
                }
            }
        }
        .frame(width: CGFloat(Preferences.contentWidth), alignment: .center)
        .padding(.vertical, 20.0)
        .padding(.horizontal, 30.0)
    }
}

struct AccountPrefsView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store()

        AccountPrefsView(
            viewModel: PrefsViewModel(store: store)
        )
    }
}
