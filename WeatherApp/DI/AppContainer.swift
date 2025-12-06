import Foundation
import UIKit

protocol Services {
    var weatherService: WeatherServiceProtocol { get }
    var locationService: LocationServiceProtocol { get }
    var imageCache: ImageCacheProtocol { get }
    var persistence: PersistenceServiceProtocol { get }
    var apiKeyProvider: ApiKeyProvider { get }
}

final class AppContainer: Services {
    let weatherService: WeatherServiceProtocol
    let locationService: LocationServiceProtocol
    let imageCache: ImageCacheProtocol
    let persistence: PersistenceServiceProtocol
    let apiKeyProvider: ApiKeyProvider
    let networkClient: NetworkClient

    init() {
        apiKeyProvider = DefaultApiKeyProvider()
        networkClient = URLSessionNetworkClient(timeout: 10)
        weatherService = WeatherService(client: networkClient, apiKeyProvider: apiKeyProvider)
        locationService = LocationService()
        imageCache = ImageCache()
        persistence = PersistenceService()
    }
}

protocol ApiKeyProvider {
    func apiKey() -> String?
}

struct DefaultApiKeyProvider: ApiKeyProvider {
    func apiKey() -> String? {
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String, !key.isEmpty {
            return key
        }
        if let env = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"], !env.isEmpty {
            return env
        }
        return nil
    }
}