//
//  HomeViewModel.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    // MARK: - Published Properties
    var currentWeather: Weather?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationServiceProtocol

    // MARK: - Constants
    private let apiKey = "" // TODO: Add your OpenWeatherMap API key

    // MARK: - Initialization
    init(
        weatherService: WeatherServiceProtocol = WeatherService(apiKey: ""),
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.weatherService = weatherService
        self.locationService = locationService
    }

    // MARK: - Public Methods

    /// Loads weather data for the user's current location
    func loadWeatherForCurrentLocation() async {
        guard !apiKey.isEmpty else {
            errorMessage = "Weather API key is not configured"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Get user's location
            let coordinates = try await locationService.requestLocation()

            // Fetch weather for that location
            let weather = try await weatherService.fetchWeather(
                lat: coordinates.latitude,
                lon: coordinates.longitude
            )

            await MainActor.run {
                self.currentWeather = weather
                self.isLoading = false
            }
        } catch let error as LocationServiceError {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        } catch let error as WeatherServiceError {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load weather: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Loads sample weather data for demonstration
    func loadSampleWeather() async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        await MainActor.run {
            self.currentWeather = Weather(
                temperature: 22.5,
                condition: .sunny,
                location: "Tokyo",
                timestamp: Date()
            )
            self.isLoading = false
        }
    }

    /// Checks if location permission has been granted
    func checkLocationPermission() -> LocationPermissionStatus {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
}

// MARK: - Supporting Types

enum LocationPermissionStatus {
    case granted
    case denied
    case notDetermined
}