// By Tom Meagher on 1/23/21 at 12:12

import Combine
import SwiftUI

struct PublishView: View {
    @EnvironmentObject
    var store: Store

    @ObservedObject
    var viewModel: PublishViewModel

    init(
        viewModel: PublishViewModel
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                if viewModel.progress > 0.0 {
                    ProgressView(value: viewModel.progress)
                }
                
                HStack {
                    Picker(selection: $viewModel.selectedJournalId, label: Text("Journal")) {
                        ForEach(store.journals) {
                            Text($0.title)
                        }
                    }
                    .disabled(viewModel.networkActive)
                    .onChange(of: viewModel.selectedJournalId, perform: viewModel.maybeSetEntryToTemplate)
                    .onChange(of: store.journals, perform: viewModel.maybeSetSelectedJournalId)
                    .onChange(of: store.token) { _ in store.fetchJournals() }
                    .onAppear(perform: store.fetchJournals)
                    .accessibility(value: Text("Selected journal: \(viewModel.selectedJournal?.title ?? "None")"))
                    
                    if let fileName = viewModel.file?.name {
                        HStack {
                            Text(fileName)
                            Button("x", action: viewModel.discardMedia)
                                .disabled(viewModel.networkActive)
                        }
                    } else {
                        Button(action: viewModel.addMedia) {
                            Text("Add media")
                            Text("(⌘ ⇧ A)")
                                .accessibility(hidden: true)
                        }
                        .disabled(viewModel.networkActive)
                        .keyboardShortcut("a", modifiers: [.command, .shift])
                        .fileImporter(
                            isPresented: $viewModel.isFileBrowserOpen,
                            allowedContentTypes: Constants.allowedContentTypes,
                            onCompletion: viewModel.attachMedia
                        )
                        .accessibility(hint: Text("Attach media to entry"))
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    if viewModel.entry.isEmpty {
                        Text("Write…")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .font(.system(size: 14))
                            .padding(.horizontal, 5)
                            .accessibility(hidden: true)
                    }
                    VStack {
                        if viewModel.networkActive || viewModel.isDragAndDropActive {
                            TextView(
                                text: $viewModel.entry,
                                isFirstResponder: false,
                                isEditable: false
                            )
                        } else {
                            TextView(
                                text: $viewModel.entry,
                                isFirstResponder: true,
                                isEditable: true
                            )
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 85, maxHeight: 85)
                }

                HStack {
                    Button(action: viewModel.publish) {
                        Text("Publish")
                        Text("(⌘ Enter)")
                            .accessibility(hidden: true)
                    }
                    .disabled(viewModel.disabled)
                    .keyboardShortcut(.return, modifiers: [.command])
                    .accessibility(hint: Text("Publish entry to Futureland"))
                    
                    Button(action: viewModel.cancel) {
                        Text("Cancel")
                        Text("(Esc)")
                            .accessibility(hidden: true)
                    }
                    .disabled(viewModel.networkActive)
                    .keyboardShortcut(.cancelAction)
                    .accessibility(hint: Text("Discard changes and close window"))

                    Spacer()

                    if viewModel.wordCount > 1 {
                        Text("\(viewModel.wordCount) words")
                            .accessibility(value: Text("Word count"))
                    }
                    
                    if !(viewModel.selectedJournal?.isPrivate ?? false) {
                        Button("\(viewModel.isPrivate ? "🔒" : "🔓")") {
                            viewModel.isPrivate = !viewModel.isPrivate
                        }
                        .disabled(viewModel.networkActive)
                        .keyboardShortcut("p", modifiers: [.command, .shift])
                        .accessibility(label: Text("\(viewModel.isPrivate ? "Private" : "Public")"))
                        .accessibility(hint: Text("Mark entry as public or private"))
                    }
                }
            }
            .padding()
            .background(Color("Background"))
            
            if viewModel.isDragAndDropActive {
                VStack {
                    Text("Drop Media")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background").opacity(0.85))
            }
        }
        .cornerRadius(10)
        .onChange(of: store.token, perform: { _ in
            if store.token == nil { viewModel.reset() }
        })
        .onDrop(
            of: Constants.allowedContentTypes,
            delegate: PublishDropDelegate(
                active: $viewModel.isDragAndDropActive,
                file: $viewModel.file
            )
        )
    }
}

struct PublishDropDelegate: DropDelegate {
    @Binding
    var active: Bool
    
    @Binding
    var file: File?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else { return false }
        
        itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) { item, _ in
            if let data = item as? Data,
               let fileUrl = URL(dataRepresentation: data, relativeTo: nil),
               let mediaFile = getFileForUrl(url: fileUrl) {
                DispatchQueue.main.async { file = mediaFile }
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // TODO: Swift bug `dropEntered` isn't called
        // - Check file type
        // - Set active to true if valid
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // TODO: Move this logic to `dropEntered` once supported
        // Determine if file type is audio, image, or video before showing active region
        guard
            info.hasItemsConforming(to: [(kUTTypeFileURL as String)]),
            let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else {
            print("cancel")
            return DropProposal(operation: .cancel)
        }
        
        if !active {
            itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) { item, _ in
                if let data = item as? Data,
                   let fileUrl = URL(dataRepresentation: data, relativeTo: nil),
                   let mediaFile = getFileForUrl(url: fileUrl),
                   ["audio", "image", "video"].contains(where: mediaFile.mimeType.contains) {
                    DispatchQueue.main.async { active = true }
                }
            }
        }
        
        return DropProposal(operation: .copy)
    }
    
    func dropExited(info: DropInfo) {
        active = false
    }
}

struct PublishView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store()
        
        PublishView(
            viewModel: PublishViewModel(
                store: store,
                onClose: { print("onClose") }
            )
        )
    }
}
