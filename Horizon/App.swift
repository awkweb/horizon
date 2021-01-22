// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI

@main
struct HorizonApp: App {
    // swiftlint:disable weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            VStack {}
        }
    }
}
