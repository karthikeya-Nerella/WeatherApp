import Foundation

protocol WeatherServiceProtocol {
    func weather(forCity city: String, countryCode: String?) async throws -> WeatherResponse
    func weather(lat: Double, lon: Double) async throws -> WeatherResponse
    func iconURL(for code: String) -> URL?
}

enum WeatherServiceError: Error {
    case missingApiKey
    case invalidResponse
    case decodingError
    case networkError(Error)
    case geocodeNotFound
}

final class WeatherService: WeatherServiceProtocol {
    private let client: NetworkClient
    private let apiKeyProvider: ApiKeyProvider

    init(client: NetworkClient = URLSessionNetworkClient(), apiKeyProvider: ApiKeyProvider) {
        self.client = client
        self.apiKeyProvider = apiKeyProvider
    }

    func weather(forCity city: String, countryCode: String?) async throws -> WeatherResponse {
        guard let key = apiKeyProvider.apiKey(), !key.isEmpty else { throw WeatherServiceError.missingApiKey }
        let q = countryCode.flatMap { "\(city),\($0)" } ?? city
        let geocodeURLString = "https://api.openweathermap.org/geo/1.0/direct?q=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q)&limit=1&appid=\(key)"
        guard let geocodeURL = URL(string: geocodeURLString) else { throw WeatherServiceError.invalidResponse }
        do {
            let (data, http) = try await client.get(geocodeURL)
            if http.statusCode == 401 { throw WeatherServiceError.missingApiKey }
            guard (200...299).contains(http.statusCode) else { throw WeatherServiceError.invalidResponse }
            let locations = try JSONDecoder().decode([GeocodeLocation].self, from: data)
            guard let first = locations.first else { throw WeatherServiceError.geocodeNotFound }
            return try await weather(lat: first.lat, lon: first.lon)
        } catch let e as DecodingError {
            throw WeatherServiceError.decodingError
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }

    func weather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard let key = apiKeyProvider.apiKey(), !key.isEmpty else { throw WeatherServiceError.missingApiKey }
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(key)&units=imperial"
        guard let url = URL(string: urlString) else { throw WeatherServiceError.invalidResponse }
        do {
            let (data, http) = try await client.get(url)
            if http.statusCode == 401 { throw WeatherServiceError.missingApiKey }
            guard (200...299).contains(http.statusCode) else { throw WeatherServiceError.invalidResponse }
            let result = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return result
        } catch let e as DecodingError {
            throw WeatherServiceError.decodingError
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }

    func iconURL(for code: String) -> URL? {
        URL(string: "https://openweathermap.org/img/wn/\(code)@2x.png")
    }
}