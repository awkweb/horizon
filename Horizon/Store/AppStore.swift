// By Tom Meagher on 1/14/21 at 21:56

import Foundation
import Combine

final class AppStore: ObservableObject {
    @Published var authUser: AuthUser?
}
