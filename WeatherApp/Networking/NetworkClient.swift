import Foundation

protocol NetworkClient {
    func get(_ url: URL) async throws -> (Data, HTTPURLResponse)
}

final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    init(timeout: TimeInterval = 10) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        session = URLSession(configuration: config)
    }

    func get(_ url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return (data, http)
    }
}