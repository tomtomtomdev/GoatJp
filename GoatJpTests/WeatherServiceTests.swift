//
//  WeatherServiceTests.swift
//  GoatJpTests
//
//  Created by Claude on 12/15/25.
//

import Foundation
import Testing
@testable import GoatJp

struct WeatherServiceTests {

    @Test("WeatherService should decode API response correctly")
    func testSuccessfulWeatherFetch() async throws {
        // Given
        let json = """
        {
            "weather": [
                {
                    "main": "Clear",
                    "description": "clear sky"
                }
            ],
            "main": {
                "temp": 25.5,
                "feels_like": 26.0
            },
            "name": "Tokyo"
        }
        """

        let mockSession = MockURLSession(
            data: json.data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        )

        let sut = WeatherService(urlSession: mockSession, apiKey: "test_key")

        // When
        let weather = try await sut.fetchWeather(lat: 35.6762, lon: 139.6503)

        // Then
        #expect(weather.temperature == 25.5)
        #expect(weather.condition == .sunny)
        #expect(weather.location == "Tokyo")
    }

    @Test("WeatherService should map cloud conditions correctly")
    func testCloudConditions() async throws {
        // Given
        let cloudyJson = """
        {
            "weather": [
                {
                    "main": "Clouds",
                    "description": "few clouds"
                }
            ],
            "main": {
                "temp": 20.0
            },
            "name": "Osaka"
        }
        """

        let mockSession = MockURLSession(
            data: cloudyJson.data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        )

        let sut = WeatherService(urlSession: mockSession, apiKey: "test_key")

        // When
        let weather = try await sut.fetchWeather(lat: 34.6937, lon: 135.5023)

        // Then
        #expect(weather.condition == .cloudy)
    }

    @Test("WeatherService should throw error on network failure")
    func testNetworkError() async {
        // Given
        let mockSession = MockURLSession(error: URLError(.notConnectedToInternet))
        let sut = WeatherService(urlSession: mockSession, apiKey: "test_key")

        // When/Then
        do {
            _ = try await sut.fetchWeather(lat: 0, lon: 0)
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as WeatherServiceError {
            if case .networkError(let message) = error {
                #expect(!message.isEmpty)
            } else {
                #expect(Bool(false), "Wrong error type")
            }
        } catch {
            #expect(Bool(false), "Wrong error type: \(error)")
        }
    }

    @Test("WeatherService should throw error on invalid response")
    func testInvalidResponse() async {
        // Given
        let mockSession = MockURLSession(
            data: Data(),
            response: HTTPURLResponse(
                url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let sut = WeatherService(urlSession: mockSession, apiKey: "invalid_key")

        // When/Then
        do {
            _ = try await sut.fetchWeather(lat: 0, lon: 0)
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as WeatherServiceError {
            #expect(error == .invalidResponse)
        } catch {
            #expect(Bool(false), "Wrong error type: \(error)")
        }
    }

    @Test("WeatherService should throw error on invalid JSON")
    func testInvalidJSON() async {
        // Given
        let mockSession = MockURLSession(
            data: "invalid json".data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let sut = WeatherService(urlSession: mockSession, apiKey: "test_key")

        // When/Then
        do {
            _ = try await sut.fetchWeather(lat: 0, lon: 0)
            #expect(Bool(false), "Should have thrown an error")
        } catch let error as WeatherServiceError {
            if case .decodingError(let message) = error {
                #expect(!message.isEmpty)
            } else {
                #expect(Bool(false), "Wrong error type")
            }
        } catch {
            #expect(Bool(false), "Wrong error type: \(error)")
        }
    }
}