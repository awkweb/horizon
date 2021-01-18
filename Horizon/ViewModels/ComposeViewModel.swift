// By Tom Meagher on 1/17/21 at 14:32

import SwiftUI
import Combine

class ComposeViewModel: ObservableObject, Identifiable {
    private(set) var store: AppStore
        
    @Published var networkActive = false
    @Published var entry = ""
    @Published var selectedJournalId: Int {
        didSet {
            UserDefaults.standard.set(selectedJournalId, forKey: "SelectedJournalId")
            print("didSet", UserDefaults.standard.integer(forKey: "SelectedJournal"), selectedJournalId)
        }
    }
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
        self.selectedJournalId = UserDefaults.standard.integer(forKey: "SelectedJournal")
        print("init", self.selectedJournalId)
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
                self.journals = journals

                print("fetch", UserDefaults.standard.integer(forKey: "SelectedJournal"))
                let selectedJournal = journals.first { $0.id == self.selectedJournalId }
                if (selectedJournal != nil) {
                    return
                }
                
                guard let journal = journals.first else {
                    return
                }
                self.selectedJournalId = journal.id
            })
            .store(in: &disposables)
    }
    
    func logout() {
        self.store.token = nil
    }
    
    func publish() {
        guard let token = store.token else {
            print("No token :(")
            return
        }
        self.networkActive = true
        Futureland
            .createEntry(token: token, notes: entry, journalId: selectedJournalId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    fatalError(error.localizedDescription)
                }
                self.networkActive = false
            }, receiveValue: { entry in
                print(entry)
                self.entry = ""
            })
            .store(in: &disposables)
    }
}

