// By Tom Meagher on 1/17/21 at 13:26

import SwiftUI
import Combine

class LoginViewModel: ObservableObject, Identifiable {
    private(set) var store: AppStore
    
    @Published var email = ""
    @Published var password = ""
    @Published var networkActive = false
    @Published var error: String?

    private var disposables = Set<AnyCancellable>()
    
    init(store: AppStore) {
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
            })
            .store(in: &disposables)
    }
}
