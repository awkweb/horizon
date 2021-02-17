// By Tom Meagher on 1/23/21 at 12:12

import Combine
import SwiftUI

struct PublishView: View {
    @EnvironmentObject
    private var store: Store

    @ObservedObject
    private var viewModel: PublishViewModel
    
    private var parent: PublishPanel
        
    init(
        viewModel: PublishViewModel,
        parent: PublishPanel
    ) {
        self.viewModel = viewModel
        self.parent = parent
    }
    
    func onChange(value: Journal?) {
        guard let journal = value else { return }
        print("onChange", journal)
    }

    var body: some View {
        VStack(spacing: 15) {
            if viewModel.progress > 0.0 {
                ProgressView(value: viewModel.progress)
            }
            
            HStack {
                Dropdown<Journal>(
                    selectedValue: $viewModel.selectedJournal,
                    items: $store.journals,
                    disabled: viewModel.networkActive,
                    getItemTitle: { $0.title.count >= 30 ? "\(String($0.title.prefix(27)))…" : $0.title },
                    onChange: onChange
                )
                .frame(width: 220.0)
                .accessibility(value: Text("Selected journal: \(viewModel.selectedJournal?.title ?? "None")"))
                .onChange(of: viewModel.selectedJournal, perform: viewModel.maybeSetEntryToTemplate)
                .onChange(of: store.journals, perform: viewModel.maybeSetSelectedJournalId)
                .onChange(of: store.token) { _ in store.fetchJournals() }
                .onAppear(perform: store.fetchJournals)
                
                Spacer()
                
                if let fileName = viewModel.file?.name {
                    HStack {
                        Text(fileName)
                            .lineLimit(1)
                            .frame(maxWidth: 150.0, alignment: .trailing)
                        
                        Button("x", action: viewModel.discardMedia)
                            .disabled(viewModel.networkActive)
                            .accessibility(label: Text("Discard attached media"))
                    }
                } else {
                    Button(action: viewModel.addMedia) {
                        Text("Add media")
                        Text("⌘ M")
                            .font(.caption)
                            .accessibility(hidden: true)
                    }
                    .disabled(viewModel.networkActive)
                    .keyboardShortcut("m", modifiers: [.command])
                    .fileImporter(
                        isPresented: $viewModel.isFileBrowserOpen,
                        allowedContentTypes: Constants.allowedContentTypes,
                        onCompletion: viewModel.attachMedia
                    )
                    .accessibility(hint: Text("Attach media to entry"))
                }
            }
            
            HorizonTextView(
                text: viewModel.entryText,
                placeholder: "Write…",
                isEditable: !(viewModel.networkActive || viewModel.isDragAndDropActive),
                onTextChange: { val in
                    self.viewModel.entryText = val
                }
            )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 85, maxHeight: 85)

            HStack {
                Button(action: viewModel.publish) {
                    Text("Publish")
                    Text("⌘ Enter")
                        .font(.caption)
                        .accessibility(hidden: true)
                }
                .disabled(viewModel.disabled)
                .keyboardShortcut(.return, modifiers: [.command])
                .accessibility(hint: Text("Publish entry to Futureland"))
                
                Button(action: viewModel.cancel) {
                    Text("Cancel")
                    Text("Esc")
                        .font(.caption)
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
                    .keyboardShortcut("p", modifiers: [.command])
                    .accessibility(label: Text("\(viewModel.isPrivate ? "Private" : "Public")"))
                    .accessibility(hint: Text("Mark entry as public or private"))
                }
                
                Button("🙂") {
                    NSApp.orderFrontCharacterPalette(nil)
                }
                .disabled(viewModel.networkActive)
                .keyboardShortcut("e", modifiers: [.command])
                .accessibility(label: Text("Show emoji picker"))
            }
        }
        .padding(.top, 5)
        .padding(.horizontal)
        .frame(width: 440)
        .overlay(
            VStack {
                if viewModel.isDragAndDropActive {
                    VStack {
                        Text("Drop Media")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("Background").opacity(0.85))
                }
            }
        )
        .onChange(of: viewModel.progress) { _ in self.parent.resize() }
        .onChange(of: store.token) { _ in
            if store.token == nil { viewModel.reset() }
        }
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
            ),
            parent: PublishPanel(
                store: store,
                onClose: { print("onClose") }
            )
        )
    }
}
