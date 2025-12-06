import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestAuthorization()
    func startUpdatingLocation(handler: @escaping (CLLocation) -> Void)
    func stopUpdatingLocation()
}

final class LocationService: NSObject, LocationServiceProtocol {
    private let manager = CLLocationManager()
    private var handler: ((CLLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    var authorizationStatus: CLAuthorizationStatus {
        CLLocationManager.authorizationStatus()
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation(handler: @escaping (CLLocation) -> Void) {
        self.handler = handler
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        handler = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        handler?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}