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
        VStack {
            HStack {
                Picker(selection: $viewModel.selectedJournalId, label: Text("Journal")) {
                    ForEach(viewModel.journals) {
                        Text($0.title)
                    }
                }
                .onChange(of: viewModel.store.token) { _ in viewModel.fetchJournals() }
                .onAppear(perform: viewModel.fetchJournals)

                if let fileName = viewModel.file?.name {
                    HStack {
                        Text(fileName)
                        Button("x", action: viewModel.discardMedia)
                    }
                } else {
                Button("Add media (⌘ ⇧ A)", action: viewModel.addMedia)
                    .keyboardShortcut("A", modifiers: [.command, .shift])
                    .fileImporter(isPresented: $viewModel.isFileBrowserOpen,
                                  allowedContentTypes: [.movie, .image, .audio],
                                  onCompletion: viewModel.attachMedia)
                }
            }

            TextEditor(text: $viewModel.entry)
                .font(.body)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 75, maxHeight: 75)

            HStack {
                Button("Publish (⌘ Enter)", action: viewModel.publish)
                    .disabled(viewModel.networkActive || (viewModel.entry.count == 0 && viewModel.file == nil ))
                    .keyboardShortcut(.return, modifiers: [.command])

                Button("Cancel", action: viewModel.cancel)
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
