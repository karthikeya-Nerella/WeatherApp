import XCTest
@testable import WeatherApp

final class WeatherServiceTests: XCTestCase {
    func testIconURL() {
        let svc = WeatherService(client: MockClient(), apiKeyProvider: StaticApiKeyProvider("key"))
        let url = svc.iconURL(for: "04d")
        XCTAssertEqual(url?.absoluteString, "https://openweathermap.org/img/wn/04d@2x.png")
    }

    func test401MapsToMissingApiKey() async {
        let client = MockClient(status: 401, body: Data())
        let svc = WeatherService(client: client, apiKeyProvider: StaticApiKeyProvider("key"))
        do {
            _ = try await svc.weather(lat: 0, lon: 0)
            XCTFail("Expected error")
        } catch let e as WeatherServiceError {
            XCTAssertEqual(e, .missingApiKey)
        } catch {
            XCTFail("Wrong error")
        }
    }
}

struct StaticApiKeyProvider: ApiKeyProvider { let k: String; func apiKey() -> String? { k } }

final class MockClient: NetworkClient {
    let status: Int
    let body: Data
    init(status: Int = 200, body: Data = Data("{}".utf8)) { self.status = status; self.body = body }
    func get(_ url: URL) async throws -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (body, response)
    }
}