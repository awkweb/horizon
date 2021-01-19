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
    @Published var isFileBrowserOpen = false
    @Published var file: File?
    
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
    
    func addMedia() {
        print("addMedia")
        isFileBrowserOpen = true
    }
    
    func attachMedia(_ result: Result<URL, Error>) {
        do {
            let fileUrl = try result.get()
            
            guard fileUrl.startAccessingSecurityScopedResource() else { return }
            guard let data = try? Data(contentsOf: fileUrl) else {
                print("Unable to read data")
                return
            }
            
            guard
                let extUTI = UTTypeCreatePreferredIdentifierForTag(
                    kUTTagClassFilenameExtension,
                    fileUrl.pathExtension as CFString,
                    nil)?.takeUnretainedValue()
            else { return }
            
            guard
                let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)
             else { return }
            
            let mimeType = mimeUTI.takeRetainedValue() as String
            print(mimeType)
            
            file = File(name: fileUrl.lastPathComponent, data: data, mimeType: mimeType)
            fileUrl.stopAccessingSecurityScopedResource()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func discardMedia() {
        file = nil
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
    
    func publish() {
        guard let token = store.token else {
            print("No token :(")
            return
        }
        self.networkActive = true
        Futureland
            .createEntry(token: token,
                         notes: entry,
                         journalId: selectedJournalId,
                         file: file)
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

