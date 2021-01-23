// By Tom Meagher on 1/23/21 at 14:22

import Foundation
import Combine

enum Futureland {
    // TODO: Standardize token passing and headers
    // https://swiftwithmajid.com/2020/01/08/building-networking-layer-using-functions/
    private static let agent = Agent()
    private static var baseURL: URL {
        guard let url = URL(string: "https://api.futureland.tv") else {
            fatalError("FAILED: https://api.futureland.tv")
        }
        return url
    }

    /// Gets journals for signed in user
    static func createEntry(token: String, notes: String, journalId: Int, file: File?) -> AnyPublisher<Entry, Error> {
        let url = baseURL.appendingPathComponent("/entries")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("token=\(token)", forHTTPHeaderField: "Cookie")

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let streakDate = formatter.string(from: now)

        let parameters = ["notes": notes, "streakDate": streakDate, "journal_id": "\(journalId)"]

        let boundary = "\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let boundaryPrefix = "--\(boundary)\r\n"
        var data = Data()
        for (key, value) in parameters {
            data.append(boundaryPrefix.data(using: .utf8, allowLossyConversion: false)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8, allowLossyConversion: false)!)
            data.append("\(value)\r\n".data(using: .utf8, allowLossyConversion: false)!)
        }

        if let fileData = file?.data,
           let fileName = file?.name,
           let mimeType = file?.mimeType {
            data.append(boundaryPrefix.data(using: .utf8, allowLossyConversion: false)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8, allowLossyConversion: false)!)
            data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8, allowLossyConversion: false)!)
            data.append(fileData)
            data.append("\r\n".data(using: .utf8, allowLossyConversion: false)!)
        }

        data.append("--".appending(boundary.appending("--")).data(using: .utf8, allowLossyConversion: false)!)
        request.httpBody = data

        return agent.run(request)
    }

    /// Gets journals for signed in user
    static func journals(token: String) -> AnyPublisher<[Journal], Error> {
        let url = baseURL.appendingPathComponent("/users/log")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token=\(token)", forHTTPHeaderField: "Cookie")

        return agent.run(request)
    }

    /// Sign in and get token
    static func login(email: String, password: String) -> AnyPublisher<AuthUser, Error> {
        let url = baseURL.appendingPathComponent("/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["email": email, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = body

        return agent.run(request)
    }
}
