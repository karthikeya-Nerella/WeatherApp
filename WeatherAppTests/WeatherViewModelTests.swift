import XCTest
import CoreLocation
@testable import WeatherApp

final class WeatherViewModelTests: XCTestCase {
    func testSearchUpdatesUIModel() async throws {
        let services = MockServices()
        let vm = WeatherViewModel(services: services)
        vm.query = "Boston"
        await vm.search()
        XCTAssertEqual(vm.uiModel?.city, "Boston")
        XCTAssertEqual(vm.uiModel?.temperature, "70°F")
        XCTAssertEqual(vm.uiModel?.description, "clear sky")
        XCTAssertNotNil(vm.uiModel?.iconURL)
    }
}

struct MockServices: Services {
    let weatherService: WeatherServiceProtocol = MockWeatherService()
    let locationService: LocationServiceProtocol = MockLocationService()
    let imageCache: ImageCacheProtocol = ImageCache()
    let persistence: PersistenceServiceProtocol = PersistenceService()
    let apiKeyProvider: ApiKeyProvider = DefaultApiKeyProvider()
}

struct MockWeatherService: WeatherServiceProtocol {
    func weather(forCity city: String, countryCode: String?) async throws -> WeatherResponse {
        WeatherResponse(coord: nil, weather: [WeatherCondition(id: 1, main: "Clear", description: "clear sky", icon: "01d")], base: nil, main: Main(temp: 70, feels_like: nil, temp_min: nil, temp_max: nil, pressure: nil, humidity: nil), visibility: nil, wind: nil, clouds: nil, dt: nil, sys: nil, timezone: nil, id: nil, name: city, cod: nil)
    }
    func weather(lat: Double, lon: Double) async throws -> WeatherResponse {
        WeatherResponse(coord: nil, weather: [WeatherCondition(id: 1, main: "Clear", description: "clear sky", icon: "01d")], base: nil, main: Main(temp: 70, feels_like: nil, temp_min: nil, temp_max: nil, pressure: nil, humidity: nil), visibility: nil, wind: nil, clouds: nil, dt: nil, sys: nil, timezone: nil, id: nil, name: "GPS", cod: nil)
    }
    func iconURL(for code: String) -> URL? { URL(string: "https://openweathermap.org/img/wn/\(code)@2x.png") }
}

final class MockLocationService: LocationServiceProtocol {
    var authorizationStatus: CLAuthorizationStatus { .authorizedWhenInUse }
    func requestAuthorization() {}
    func startUpdatingLocation(handler: @escaping (CLLocation) -> Void) { handler(CLLocation(latitude: 0, longitude: 0)) }
    func stopUpdatingLocation() {}
}