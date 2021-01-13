// By Tom Meagher on 1/13/21 at 17:14

import SwiftUI

struct AuthUser: Codable {
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var networkActive = false
    
    private func onClickLogin() {
        print("onClickLogin")
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
                self.networkActive = false
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
                self.networkActive = false
                return
            }
            
            guard let mime = httpResponse.mimeType, mime == "application/json" else {
                print("Wrong MIME type")
                self.networkActive = false
                return
            }
            
            let user = try! JSONDecoder().decode(AuthUser.self, from: data!)
            print("token \(user.token)")
            self.networkActive = false
        }

        task.resume()
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                Button("Login", action: self.onClickLogin)
                    .disabled(networkActive)
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
