// By Tom Meagher on 1/14/21 at 21:58

import SwiftUI

struct ComposeView: View {
    @EnvironmentObject var store: AppStore
    @ObservedObject var viewModel: ComposeViewModel
    
    init(viewModel: ComposeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if (store.token != nil) {
                VStack {
                    HStack {
                        Picker(selection: $viewModel.selectedJournalId, label: Text("Journal")) {
                            ForEach(viewModel.journals) {
                                Text($0.title)
                            }
                        }
                        .onAppear(perform: viewModel.fetch)
                        
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
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    
                    HStack {
                        Button("Publish (⌘ Enter)", action: viewModel.publish)
                            .disabled(viewModel.networkActive || (viewModel.entry.count == 0 && viewModel.file == nil ))
                            .keyboardShortcut(.return, modifiers: [.command])
                        
                        Spacer()
                        
                        if viewModel.wordCount > 1 {
                            Text("\(viewModel.wordCount) words")
                        }
                    }
                }
            }
        }.padding()
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(viewModel: ComposeViewModel(store: AppStore()))
    }
}
