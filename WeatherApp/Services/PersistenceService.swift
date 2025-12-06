import Foundation

protocol PersistenceServiceProtocol {
    func lastCity() -> String?
    func setLastCity(_ city: String)
}

final class PersistenceService: PersistenceServiceProtocol {
    private let defaults = UserDefaults.standard
    private let key = "lastCity"

    func lastCity() -> String? {
        defaults.string(forKey: key)
    }

    func setLastCity(_ city: String) {
        defaults.set(city, forKey: key)
    }
}