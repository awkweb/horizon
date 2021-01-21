// By Tom Meagher on 1/14/21 at 21:56

import Foundation
import Combine
import SwiftUI

final class AppStore: ObservableObject {
    @AppStorage("Token") var token: String?
    @Published var user: User?
}
