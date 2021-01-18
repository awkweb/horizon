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
                        
                        Button("Log out", action: viewModel.logout)
                    }
                    
                    TextEditor(text: $viewModel.entry)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    
                    HStack {
                        Button("Publish", action: viewModel.publish)
                            .disabled(viewModel.entry.count == 0)
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
