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
    var entryText = ""
    
    @Published
    var selectedJournal: Journal? {
        didSet {
            previousSelectedJournal = store.journals.first { $0.id == oldValue?.id }
        }
    }
    
    @Published
    var isDragAndDropActive = false

    @Published
    var isFileBrowserOpen = false
    
    @Published
    var isPrivate = false

    @Published
    var file: File?
    
    var disabled: Bool { networkActive || (entryText.isEmpty && file == nil ) }
    var wordCount: Int { entryText.split { $0 == " " || $0.isNewline }.count }
    
    var previousSelectedJournal: Journal?
    
    init(
        store: Store,
        onClose: @escaping () -> Void
    ) {
        self.store = store
        self.onClose = onClose
    }

    func publish() {
        guard let token = store.token else { return }

        networkActive = true

        Futureland
            .createEntry(
                token: token,
                notes: entryText,
                journalId: selectedJournal!.id,
                file: file,
                isPrivate: isPrivate
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
                guard let username = self.store.user?.username else { return }
                guard let slug = self.selectedJournal?.slug else { return }
                
                let entryUrl = "https://futureland.tv/\(username)/\(slug)/\(entry.id)?fullscreen=1"
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
        isPrivate = false
        file = nil
        entryText = ""
        
        if let journal = selectedJournal {
            setEntryToTemplate(journal: journal)
        }
        
        onClose()
    }
    
    func onChangeJournal(value: Journal?) {
        guard let journal = value else { return }
        
        setEntryToTemplate(journal: journal)
        isPrivate = journal.isPrivate
    }
}

// MARK: Media
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

            guard let mediaFile = getFileForUrl(url: fileUrl) else { return }
            
            file = mediaFile
            
            fileUrl.stopAccessingSecurityScopedResource()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: Entry template
extension PublishViewModel {
    private func setEntryToTemplate(journal: Journal) {
        if entryText != previousSelectedJournal?.entryTemplate ?? "" { return }
                
        guard let template = journal.entryTemplate else {
            entryText = ""
            return
        }
        
        if journal.entryTemplateActive || template.isEmpty {
            entryText = template
        }
    }
}
