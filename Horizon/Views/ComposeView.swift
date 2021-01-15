// By Tom Meagher on 1/14/21 at 21:58

import SwiftUI

struct ComposeView: View {
    @EnvironmentObject var store: AppStore
    @State private var networkActive = false
    
    private func onClickLogOut() {
        print("onClickLogin")
        guard let url = URL(string: "https://futureland.tv/api/auth/logout") else {
            print("Invalid URL")
            return
        }
        
        networkActive = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token=\(store.authUser!.token)", forHTTPHeaderField: "Cookie")
        
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
                self.store.authUser = nil
            }
        }

        task.resume()
    }

    var body: some View {
        VStack {
            if (store.authUser != nil) {
                Text("@\(store.authUser!.user.username)")
                Button("Log out", action: self.onClickLogOut)
                    .disabled(networkActive)
            }
        }.padding()
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView()
    }
}
