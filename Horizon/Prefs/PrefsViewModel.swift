// By Tom Meagher on 1/23/21 at 14:14

import SwiftUI
import Combine

class PrefsViewModel: ObservableObject, Identifiable {
    private(set) var store: Store
    private var disposables = Set<AnyCancellable>()

    @Published
    var email = ""

    @Published
    var password = ""

    @Published
    var networkActive = false

    @Published
    var error: String?

    init(
        store: Store
    ) {
        self.store = store
    }

    func login() {
        self.networkActive = true
        Futureland
            .login(email: email, password: password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self.error = "wrong credentials"
                }
                self.networkActive = false
            }, receiveValue: { authUser in
                self.store.token = authUser.token
                self.store.user = authUser.user

                self.email = ""
                self.password = ""
            })
            .store(in: &disposables)
    }

    func logout() {
        self.store.token = nil
    }
}
