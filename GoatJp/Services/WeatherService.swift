//
//  WeatherService.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation

/// Protocol for weather service dependency injection
protocol WeatherServiceProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather
}

/// Errors that can occur during weather fetching
enum WeatherServiceError: LocalizedError, Equatable {
    case networkError(String)
    case invalidResponse
    case decodingError(String)
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .decodingError(let message):
            return "Failed to decode weather data: \(message)"
        case .apiKeyMissing:
            return "Weather API key is missing"
        }
    }
}

/// Service for fetching weather data from OpenWeatherMap API
final class WeatherService: WeatherServiceProtocol {
    private let urlSession: URLSessionProtocol
    private let apiKey: String

    /// Base URL for OpenWeatherMap API
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    init(urlSession: URLSessionProtocol = URLSession.shared, apiKey: String) {
        self.urlSession = urlSession
        self.apiKey = apiKey
    }

    /// Fetches weather data for the given coordinates
    /// - Parameters:
    ///   - lat: Latitude
    ///   - lon: Longitude
    /// - Returns: Weather object with current conditions
    /// - Throws: WeatherServiceError if the fetch fails
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        guard !apiKey.isEmpty else {
            throw WeatherServiceError.apiKeyMissing
        }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components.url else {
            throw WeatherServiceError.invalidResponse
        }

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw WeatherServiceError.invalidResponse
            }

            let weatherResponse = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
            return weatherResponse.toWeather()
        } catch let error as WeatherServiceError {
            throw error
        } catch {
            if error is URLError {
                throw WeatherServiceError.networkError(error.localizedDescription)
            } else {
                throw WeatherServiceError.decodingError(error.localizedDescription)
            }
        }
    }
}

// MARK: - API Response Models

private struct WeatherAPIResponse: Codable {
    let weather: [WeatherCondition]
    let main: MainWeather
    let name: String

    struct WeatherCondition: Codable {
        let main: String
        let description: String
    }

    struct MainWeather: Codable {
        let temp: Double
        let feels_like: Double
    }

    func toWeather() -> Weather {
        let condition = mapWeatherCondition(weather.first?.main ?? "")
        return Weather(
            temperature: main.temp,
            condition: condition,
            location: name,
            timestamp: Date()
        )
    }

    private func mapWeatherCondition(_ main: String) -> Weather.Condition {
        switch main.lowercased() {
        case "clear":
            return .sunny
        case "clouds":
            return .cloudy
        case "rain", "drizzle":
            return .raining
        case "snow":
            return .snow
        default:
            return .sunBehindCloud
        }
    }
}