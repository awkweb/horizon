// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI

@main
struct HorizonApp: App {
    @StateObject var store = AppStore()
    @NSApplicationDelegateAdaptor(AppDelegate.self) weak var appDelegate

    var body: some Scene {
        WindowGroup {
            VStack {}
        }
    }
}
