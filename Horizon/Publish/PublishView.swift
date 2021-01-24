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
        VStack(spacing: 10) {
            if viewModel.progress > 0.0 {
                ProgressView(value: viewModel.progress)
            }
            
            HStack {
                Picker(selection: $viewModel.selectedJournalId, label: Text("Journal")) {
                    ForEach(viewModel.journals) {
                        Text($0.title)
                    }
                }
                .disabled(viewModel.networkActive)
                .onChange(of: viewModel.store.token) { _ in viewModel.fetchJournals() }
                .onAppear(perform: viewModel.fetchJournals)

                if let fileName = viewModel.file?.name {
                    HStack {
                        Text(fileName)
                        Button("x", action: viewModel.discardMedia)
                            .disabled(viewModel.networkActive)
                    }
                } else {
                Button("Add media (⌘ ⇧ A)", action: viewModel.addMedia)
                    .disabled(viewModel.networkActive)
                    .keyboardShortcut("A", modifiers: [.command, .shift])
                    .fileImporter(isPresented: $viewModel.isFileBrowserOpen,
                                  allowedContentTypes: [.movie, .image, .audio],
                                  onCompletion: viewModel.attachMedia)
                }
            }

            TextEditor(text: $viewModel.entry)
                .disabled(viewModel.networkActive)
                .font(.body)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 75, maxHeight: 75)

            HStack {
                Button("Publish (⌘ Enter)", action: viewModel.publish)
                    .disabled(viewModel.disabled)
                    .keyboardShortcut(.return, modifiers: [.command])

                Button("Cancel", action: viewModel.cancel)
                    .disabled(viewModel.networkActive)
                    .keyboardShortcut(.escape)

                Spacer()

                if viewModel.wordCount > 1 {
                    Text("\(viewModel.wordCount) words")
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .cornerRadius(10)
        .onChange(of: store.token, perform: { _ in
            if store.token == nil { viewModel.reset() }
        })
    }
}

struct PublishView_Previews: PreviewProvider {
    static var previews: some View {
        PublishView(
            viewModel: PublishViewModel(
                store: Store(),
                onClose: { print("onClose") }
            )
        )
    }
}
