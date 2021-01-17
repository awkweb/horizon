// By Tom Meagher on 1/17/21 at 14:32

import SwiftUI
import Combine

class ComposeViewModel: ObservableObject, Identifiable {
    private(set) var store: AppStore
        
    @Published var networkActive = false
    @Published var entry = ""
    @Published var selectedJournal: Int = 0
    @Published var journals = [Journal]()
    
    var wordCount: Int {
        // TODO: Fix greedy word count
        entry
            .split(separator: " ")
            .flatMap { $0.split(separator: "\n")}
            .count
    }

    private var disposables = Set<AnyCancellable>()
    
    init(store: AppStore) {
        self.store = store
    }
    
    func fetch() {
        guard let token = store.token else {
            print("No token :(")
            return
        }
        self.networkActive = true
        Futureland
            .journals(token: token)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                self.networkActive = false
            }, receiveValue: { journals in
                print(journals)
                self.selectedJournal = journals.first?.id ?? 0
                self.journals = journals
            })
            .store(in: &disposables)
    }
    
    func logout() {
        self.store.token = nil
    }
}

