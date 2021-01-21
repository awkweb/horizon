// By Tom Meagher on 1/14/21 at 22:06

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var window: NSPanel

    init(window: NSPanel) {
        self.window = window
    }

    var body: some View {
        VStack {
            if store.token != nil {
                ComposeView(viewModel: ComposeViewModel(store: store, window: window))
            } else {
                LoginView(viewModel: LoginViewModel(store: store))
            }
        }
        .environmentObject(store)
        .background(Color.black)
        .cornerRadius(10)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(window: NSPanel())
    }
}
