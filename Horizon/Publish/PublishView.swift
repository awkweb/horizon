// By Tom Meagher on 1/23/21 at 12:12

import Combine
import SwiftUI
import UniformTypeIdentifiers

let allowedContentTypes: [UTType] = [.movie, .video, .image, .audio]

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
                    
                    if let fileName = viewModel.file?.name {
                        HStack {
                            Text(fileName)
                            Button("x", action: viewModel.discardMedia)
                                .disabled(viewModel.networkActive)
                        }
                    } else {
                        Button("Add media (⌘ ⇧ A)", action: viewModel.addMedia)
                            .disabled(viewModel.networkActive)
                            .keyboardShortcut("a", modifiers: [.command, .shift])
                            .fileImporter(
                                isPresented: $viewModel.isFileBrowserOpen,
                                allowedContentTypes: allowedContentTypes,
                                onCompletion: viewModel.attachMedia
                            )
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    if viewModel.entry.isEmpty {
                        Text("Write…")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .font(.system(size: 14))
                            .padding(.horizontal, 5)
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
                    Button("Publish (⌘ Enter)", action: viewModel.publish)
                        .disabled(viewModel.disabled)
                        .keyboardShortcut(.return, modifiers: [.command])

                    Button("Cancel (Esc)", action: viewModel.cancel)
                        .disabled(viewModel.networkActive)
                        .keyboardShortcut(.cancelAction)

                    Spacer()

                    if viewModel.wordCount > 1 {
                        Text("\(viewModel.wordCount) words")
                    }
                    
                    if !(viewModel.selectedJournal?.isPrivate ?? false) {
                        Button("\(viewModel.isPrivate ? "🔒" : "🔓")") {
                            viewModel.isPrivate = !viewModel.isPrivate
                        }
                        .disabled(viewModel.networkActive)
                        .keyboardShortcut("p", modifiers: [.command, .shift])
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
                .background(Color.gray.opacity(0.2))
            }
        }
        .cornerRadius(10)
        .onChange(of: store.token, perform: { _ in
            if store.token == nil { viewModel.reset() }
        })
        .onDrop(
            of: allowedContentTypes,
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
            guard let data = item as? Data else { return }
            
            if let fileUrl = URL(dataRepresentation: data, relativeTo: nil) {
                guard fileUrl.startAccessingSecurityScopedResource() else { return }
                guard let mediaFile = getFileForUrl(url: fileUrl) else { return }
                
                DispatchQueue.main.async { file = mediaFile }
                
                fileUrl.stopAccessingSecurityScopedResource()
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        active = true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if !active { active = true }
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
