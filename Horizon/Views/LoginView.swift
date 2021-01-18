// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Email", text: $viewModel.email)
                
                SecureField("Password", text: $viewModel.password)
                
                HStack {
                    Button("Login", action: viewModel.login)
                        .disabled(viewModel.networkActive)
                        .keyboardShortcut(.return, modifiers: [.command])
                    Spacer()
                    if let error = viewModel.error {
                        Text(error)
                    }
                }
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(store: AppStore()))
    }
}
