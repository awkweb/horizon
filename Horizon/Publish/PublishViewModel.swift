// By Tom Meagher on 1/23/21 at 14:28

import SwiftUI
import Combine
import UserNotifications

class PublishViewModel: ObservableObject, Identifiable {
    private(set) var store: Store
    private let onClose: () -> Void
    private var disposables = Set<AnyCancellable>()

    @Published
    var networkActive = false
    
    @Published
    var progress = 0.0

    @Published
    var entry = ""
    
    @Published
    var selectedJournalId: Int = 0 {
        didSet {
            previousSelectedJournal = journals.first { $0.id == oldValue }
        }
    }

    @Published
    var journals = [Journal]()

    @Published
    var isFileBrowserOpen = false

    @Published
    var file: File?
    
    var disabled: Bool { networkActive || (entry.count == 0 && file == nil ) }
    var wordCount: Int { entry.split { $0 == " " || $0.isNewline }.count }
    
    var selectedJournal: Journal? { journals.first { $0.id == self.selectedJournalId } }
    var previousSelectedJournal: Journal?
    
    init(
        store: Store,
        onClose: @escaping () -> Void
    ) {
        self.store = store
        self.onClose = onClose
    }

    func cancel() {
        reset()
    }

    func fetchJournals() {
        guard let token = store.token else { return }

        networkActive = true

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
                let sortedJournals = journals.sorted { (a, b) -> Bool in
                    guard let lastEntryAtA = a.lastEntryAt else { return false }
                    guard let lastEntryAtB = b.lastEntryAt else { return true }
                    return lastEntryAtA > lastEntryAtB
                }
                self.journals = sortedJournals

                // Check if a journal is already selected
                let selectedJournal = sortedJournals.first { $0.id == self.selectedJournalId }
                if selectedJournal != nil { return }

                // Select first journal if none are selected
                guard let journal = sortedJournals.first else { return }
                self.selectedJournalId = journal.id
            })
            .store(in: &disposables)
    }

    func publish() {
        guard let token = store.token else { return }

        networkActive = true

        Futureland
            .createEntry(
                token: token,
                notes: entry,
                journalId: selectedJournalId,
                file: file
            )
            .uploadProgress { progress in
                self.progress = progress.fractionCompleted
            }
            .publishDecodable(type: Entry.self)
            .value()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                self.networkActive = false
            }, receiveValue: { entry in                
                let entryUrl = "https://futureland.tv/\(self.store.username!)/\(self.selectedJournal!.slug)/\(entry.id)?fullscreen=1"
                let content = UNMutableNotificationContent()
                content.title = "Published Entry"
                content.body = entry.notes
                content.userInfo = ["entryUrl": entryUrl]
                content.categoryIdentifier = Notifications.Categories.publishedEntry
                
                let uuidString = UUID().uuidString
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(
                    identifier: uuidString,
                    content: content,
                    trigger: trigger
                )
                
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request) { (error) in
                   if let error = error {
                      print(error)
                   }
                }
                
                self.reset()
            })
            .store(in: &disposables)
    }

    func reset() {
        progress = 0.0
        networkActive = false
        file = nil
        entry = ""
        
        maybeSetEntryToTemplate(journalId: selectedJournalId)
        
        onClose()
    }
}

// MARK: Add media
extension PublishViewModel {
    func addMedia() {
        isFileBrowserOpen = true
    }
    
    func discardMedia() {
        file = nil
    }

    func attachMedia(_ result: Result<URL, Error>) {
        do {
            let fileUrl = try result.get()
            guard fileUrl.startAccessingSecurityScopedResource() else { return }

            // Get file data
            guard let data = try? Data(contentsOf: fileUrl) else {
                print("Unable to read data")
                return
            }

            // Get mime type
            guard let mimeType = getMimeTypeFor(fileUrl: fileUrl) else {
                print("Unable to get mime type")
                return
            }

            file = File(name: fileUrl.lastPathComponent, data: data, mimeType: mimeType)
            fileUrl.stopAccessingSecurityScopedResource()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: Entry template
extension PublishViewModel {
    func maybeSetEntryToTemplate(journalId id: Int) {
        if entry != previousSelectedJournal?.entryTemplate ?? "" {
            return
        }
        
        guard let journal = journals.first(where: { $0.id == id }) else {
            return
        }
                
        guard let template = journal.entryTemplate else {
            entry = ""
            return
        }
        
        if journal.entryTemplateActive {
            entry = template
        }
    }
}
