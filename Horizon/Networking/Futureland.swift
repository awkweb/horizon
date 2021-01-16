// By Tom Meagher on 1/15/21 at 19:14

import Foundation

enum Futureland {
    /// Creates entry for journal
    case createEntry(_ notes: String,
                     journal: String,
                     file: String?,
                     streakDate: String?)
    
    /// Gets journals for signed in user
    case journals
    
    /// Sign in and get token
    case login(username: String,
               password: String)
    
    /// Sign out
    case logout
}

extension Futureland {
    var baseURL: URL {
        guard let url = URL(string: "https://api.futureland.tv") else {
            fatalError("FAILED: https://api.futureland.tv")
        }
        return url
    }
}
