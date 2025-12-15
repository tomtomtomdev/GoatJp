//
//  WeatherTests.swift
//  GoatJpTests
//
//  Created by Claude on 12/15/25.
//

import Foundation
import Testing
@testable import GoatJp

struct WeatherTests {

    @Test("Weather condition should have correct icon mapping")
    func testWeatherConditionIconMapping() {
        #expect(Weather.Condition.sunny.iconName == "sun.max.fill")
        #expect(Weather.Condition.cloudy.iconName == "cloud.fill")
        #expect(Weather.Condition.sunBehindCloud.iconName == "cloud.sun.fill")
        #expect(Weather.Condition.raining.iconName == "cloud.rain.fill")
        #expect(Weather.Condition.snow.iconName == "snow")
    }

    @Test("Weather should be created with correct properties")
    func testWeatherCreation() {
        let weather = Weather(
            temperature: 25.5,
            condition: .sunny,
            location: "Tokyo",
            timestamp: Date()
        )

        #expect(weather.temperature == 25.5)
        #expect(weather.condition == .sunny)
        #expect(weather.location == "Tokyo")
        #expect(abs(weather.timestamp.timeIntervalSinceNow) < 1.0)
    }

    @Test("Weather should format temperature correctly")
    func testTemperatureFormatting() {
        let hotWeather = Weather(temperature: 30.0, condition: .sunny, location: "Tokyo", timestamp: Date())
        let coldWeather = Weather(temperature: -5.5, condition: .snow, location: "Sapporo", timestamp: Date())

        #expect(hotWeather.formattedTemperature == "30°C")
        #expect(coldWeather.formattedTemperature == "-6°C")
    }

    @Test("Weather should detect extreme conditions")
    func testExtremeConditions() {
        let hotWeather = Weather(temperature: 35.0, condition: .sunny, location: "Tokyo", timestamp: Date())
        let coldWeather = Weather(temperature: -10.0, condition: .snow, location: "Sapporo", timestamp: Date())
        let mildWeather = Weather(temperature: 20.0, condition: .cloudy, location: "Osaka", timestamp: Date())

        #expect(hotWeather.isExtreme == true)
        #expect(coldWeather.isExtreme == true)
        #expect(mildWeather.isExtreme == false)
    }
}