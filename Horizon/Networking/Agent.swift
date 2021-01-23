// By Tom Meagher on 1/23/21 at 14:22

import Foundation
import Combine

struct Agent {
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveOutput: { print(NSString(data: $0, encoding: String.Encoding.utf8.rawValue)!) })
            .decode(type: T.self, decoder: decoder)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
