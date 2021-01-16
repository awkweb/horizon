// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var email = ""
    @State private var password = ""
    @State private var networkActive = false
    
    private func login() {
        print("login")
        guard let url = URL(string: "https://futureland.tv/api/auth/login") else {
            print("Invalid URL")
            return
        }
        
        networkActive = true
        let json: [String: Any] = ["email": email, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
            
            guard let mime = httpResponse.mimeType, mime == "application/json" else {
                print("Wrong MIME type")
                networkActive = false
                return
            }
            
            let authUser = try! JSONDecoder().decode(AuthUser.self, from: data!)
            DispatchQueue.main.async {
                self.store.token = authUser.token
                self.store.user = authUser.user
            }
        }

        task.resume()
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Email", text: $email)
                
                SecureField("Password", text: $password)
                
                Button("Login", action: self.login)
                    .disabled(networkActive)
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
