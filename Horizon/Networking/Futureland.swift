// By Tom Meagher on 1/15/21 at 19:14

import Foundation
import Combine

enum Endpoint: String {
    /// Gets journals for signed in user
    case journals = "/users/log"
    /// Sign in and get token
    case login = "/auth/login"
    /// Sign out
    case logout = "/auth/logout"
}

enum Futureland {
    private static let agent = Agent()
    private static var baseURL: URL {
        guard let url = URL(string: "https://api.futureland.tv") else {
            fatalError("FAILED: https://api.futureland.tv")
        }
        return url
    }
    
    static func journals(token: String) -> AnyPublisher<[Journal], Error> {
        let url = baseURL.appendingPathComponent(Endpoint.journals.rawValue)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token=\(token)", forHTTPHeaderField: "Cookie")
        
        return agent.run(request)
    }
    
    static func login(email: String, password: String) -> AnyPublisher<AuthUser, Error> {
        let url = baseURL.appendingPathComponent(Endpoint.login.rawValue)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["email": email, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = body
        
        return agent.run(request)
    }
}
