// By Tom Meagher on 1/14/21 at 21:58

import SwiftUI

struct ComposeView: View {
    var journals = ["⛈", "Futureland Meta", "Horizon", "Disconnecting", "Sky"]
    
    @EnvironmentObject var store: AppStore
    @State private var networkActive = false
    @State private var entry: String = ""
    @State private var selectedJournal = 0
    
    var wordCount: Int {
        // TODO: Fix greedy word count
        entry
            .split(separator: " ")
            .flatMap { $0.split(separator: "\n")}
            .count
    }
    
    private func logOut() {
        print("logOut")
        guard let url = URL(string: "https://futureland.tv/api/auth/logout") else {
            print("Invalid URL")
            return
        }
        
        guard let token = store.token else {
            print("No token")
            return
        }
        
        networkActive = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token=\(token)", forHTTPHeaderField: "Cookie")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil || data == nil {
                print("Client error")
                networkActive = false
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
                networkActive = false
                return
            }
            
            DispatchQueue.main.async {
                self.store.token = nil
            }
        }

        task.resume()
    }
    
    private func publish() {}

    var body: some View {
        VStack {
            if (store.token != nil) {
                VStack {
                    HStack {
                        Picker(selection: $selectedJournal, label: Text("Journal")) {
                            ForEach(0 ..< journals.count) {
                                Text(self.journals[$0])
                            }
                        }
                        
                        HStack {
                            Spacer()
                            if (store.user != nil) {
                                Text("@\(store.user!.username)")
                            }
                            Button("Log out", action: self.logOut)
                                .disabled(networkActive)
                        }
                    }
                    
                    TextEditor(text: $entry)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    
                    HStack {
                        if wordCount > 1 {
                            Text("\(wordCount) words")
                        }
                        Spacer()
                        Button("Publish", action: self.publish)
                            .disabled(entry.count == 0)
                    }
                }
            }
        }.padding()
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView()
            .environmentObject(AppStore())
    }
}
