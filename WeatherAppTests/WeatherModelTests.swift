import XCTest
@testable import WeatherApp

final class WeatherModelTests: XCTestCase {
    func testDecodeWeatherResponse() throws {
        let json = """
        {
          "weather": [
            {
              "id": 500,
              "main": "Rain",
              "description": "light rain",
              "icon": "10d"
            }
          ],
          "main": {
            "temp": 72.5
          },
          "name": "Austin"
        }
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(WeatherResponse.self, from: json)
        XCTAssertEqual(resp.name, "Austin")
        XCTAssertEqual(Int(resp.main.temp.rounded()), 72)
        XCTAssertEqual(resp.weather.first?.icon, "10d")
    }
}