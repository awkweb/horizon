// By Tom Meagher on 1/29/21 at 22:21

import Alamofire
import Combine
import Foundation
import KeychainAccess
import SwiftUI

let keychain = Keychain()

class Store: ObservableObject {
    private var disposables = Set<AnyCancellable>()
    
    @Published
    var journals = [Journal]()
    
    @Published
    var token: String? {
        didSet {
            keychainSet(value: token, key: "Token")
        }
    }

    @Published
    var user: User? {
        didSet {
            keychainSet(value: user, key: "User")
        }
    }

    init() {
        guard let token: String = keychainGet(key: "Token") else { return }
        self.token = token
        
        guard let user: User = keychainGet(key: "User") else { return }
        self.user = user
    }
    
    func fetchJournals() {
        guard let token = token else { return }
        Futureland
            .journals(token: token)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                    }
                },
                receiveValue: { journals in
                    let sortedJournals = journals.sorted { (a, b) -> Bool in
                        guard let lastEntryAtA = a.lastEntryAt else { return false }
                        guard let lastEntryAtB = b.lastEntryAt else { return true }
                        return lastEntryAtA > lastEntryAtB
                    }
                    self.journals = sortedJournals
                }
            )
            .store(in: &disposables)
    }
}

extension Store {
    private func keychainSet<T: Codable>(value: T, key: String) {
        do {
            let encoded = try JSONEncoder().encode(value)
            try keychain.set(encoded, key: key)
        } catch let error {
            print(error)
        }
    }
    
    private func keychainGet<T: Codable>(key: String) -> T? {
        var value: T?
        do {
            try keychain.get(key) { attributes in
                if let attributes = attributes,
                   let data = attributes.data {
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        value = decoded
                    } catch let error {
                        print(error)
                    }
                }
            }
        } catch let error {
            print(error)
        }
        
        return value
    }
}
