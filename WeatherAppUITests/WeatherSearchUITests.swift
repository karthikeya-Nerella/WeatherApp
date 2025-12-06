import XCTest

final class WeatherSearchUITests: XCTestCase {
    func testSearchFlowSuccess() {
        let app = XCUIApplication()
        app.launchEnvironment["OPENWEATHER_API_KEY"] = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"] ?? ""
        app.launch()

        let cityField = app.textFields["cityTextField"]
        XCTAssertTrue(cityField.waitForExistence(timeout: 5))
        cityField.tap()
        cityField.typeText("Austin")

        let searchButton = app.buttons["searchButton"]
        XCTAssertTrue(searchButton.exists)
        searchButton.tap()

        let austinLabel = app.staticTexts["Austin"]
        XCTAssertTrue(austinLabel.waitForExistence(timeout: 10))
        let icon = app.images["weatherIcon"]
        XCTAssertTrue(icon.exists)
    }

    func testErrorStateMissingApiKey() {
        let app = XCUIApplication()
        app.launchEnvironment["OPENWEATHER_API_KEY"] = ""
        app.launch()

        let cityField = app.textFields["cityTextField"]
        XCTAssertTrue(cityField.waitForExistence(timeout: 5))
        cityField.tap()
        cityField.typeText("Austin")

        let searchButton = app.buttons["searchButton"]
        XCTAssertTrue(searchButton.exists)
        searchButton.tap()

        let errorText = app.staticTexts["Missing API key"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 10))
    }
}