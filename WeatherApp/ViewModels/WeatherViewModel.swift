import Foundation
import CoreLocation

@MainActor
final class WeatherViewModel: ObservableObject {
    struct UIModel {
        let city: String
        let temperature: String
        let description: String
        let iconURL: URL?
    }

    @Published var query: String = ""
    @Published var uiModel: UIModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let services: Services

    init(services: Services) {
        self.services = services
    }

    func onAppear() {
        requestLocationPermission()
        loadInitial()
    }

    func requestLocationPermission() {
        services.locationService.requestAuthorization()
    }

    func loadInitial() {
        let status = services.locationService.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            services.locationService.startUpdatingLocation { [weak self] loc in
                Task { await self?.fetchByLocation(location: loc) }
            }
        } else if let last = services.persistence.lastCity(), !last.isEmpty {
            query = last
            Task { await search() }
        }
    }

    func search() async {
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await services.weatherService.weather(forCity: query, countryCode: "US")
            let icon = resp.weather.first?.icon ?? ""
            let url = services.weatherService.iconURL(for: icon)
            let temp = Int(resp.main.temp.rounded())
            uiModel = UIModel(city: resp.name, temperature: "\(temp)°F", description: resp.weather.first?.description ?? "", iconURL: url)
            services.persistence.setLastCity(query)
        } catch {
            errorMessage = displayableError(error)
        }
        isLoading = false
    }

    func fetchByLocation(location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await services.weatherService.weather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            let icon = resp.weather.first?.icon ?? ""
            let url = services.weatherService.iconURL(for: icon)
            let temp = Int(resp.main.temp.rounded())
            uiModel = UIModel(city: resp.name, temperature: "\(temp)°F", description: resp.weather.first?.description ?? "", iconURL: url)
        } catch {
            errorMessage = displayableError(error)
        }
        isLoading = false
        services.locationService.stopUpdatingLocation()
    }

    private func displayableError(_ error: Error) -> String {
        if let e = error as? WeatherServiceError {
            switch e {
            case .missingApiKey: return "Missing API key"
            case .invalidResponse: return "Invalid response"
            case .decodingError: return "Decoding error"
            case .networkError(let err): return err.localizedDescription
            case .geocodeNotFound: return "Location not found"
            }
        }
        return "Unexpected error"
    }
}