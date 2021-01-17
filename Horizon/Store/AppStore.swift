// By Tom Meagher on 1/14/21 at 21:56

import Foundation
import Combine

final class AppStore: ObservableObject {
    @Published var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "Token")
        }
    }
    
    @Published var user: User?
    
    private var anyCancellable: AnyCancellable?
    
    init() {
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            return
        }
        self.token = token
    }
}
