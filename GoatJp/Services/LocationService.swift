//
//  LocationService.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation
import CoreLocation

/// Protocol for location service dependency injection
protocol LocationServiceProtocol {
    func requestLocation() async throws -> LocationCoordinates
    var authorizationStatus: CLAuthorizationStatus { get }
}

/// Errors that can occur during location fetching
enum LocationServiceError: LocalizedError, Equatable {
    case permissionDenied
    case locationUnavailable
    case timeout

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied. Please enable it in Settings."
        case .locationUnavailable:
            return "Unable to determine your location at this time."
        case .timeout:
            return "Location request timed out."
        }
    }
}

/// Simple location coordinates model
struct LocationCoordinates: Equatable {
    let latitude: Double
    let longitude: Double
}

/// Service for handling location permissions and fetching user location
final class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager: CLLocationManagerProtocol
    private let continuation = AsyncStream<LocationCoordinates>.makeStream()

    /// Current authorization status
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }

    /// Initialize with location manager
    /// - Parameter locationManager: CLLocationManager instance for testing
    init(locationManager: CLLocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
    }

    /// Request location permission and fetch current location
    /// - Returns: User's current coordinates
    /// - Throws: LocationServiceError if permission denied or location unavailable
    func requestLocation() async throws -> LocationCoordinates {
        // Check authorization status
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission already granted, fetch location
            return try await fetchLocation()

        case .notDetermined:
            // Request permission
            locationManager.requestWhenInUseAuthorization()
            // Try to fetch location (might need to wait for permission)
            return try await fetchLocationWithRetry()

        case .denied, .restricted:
            throw LocationServiceError.permissionDenied

        @unknown default:
            throw LocationServiceError.permissionDenied
        }
    }

    // MARK: - Private Methods

    private func fetchLocation() async throws -> LocationCoordinates {
        do {
            let location = try await locationManager.requestLocation()
            return LocationCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } catch {
            if error is LocationError {
                throw LocationServiceError.locationUnavailable
            } else {
                throw LocationServiceError.locationUnavailable
            }
        }
    }

    private func fetchLocationWithRetry() async throws -> LocationCoordinates {
        // Try to fetch location with a short delay to allow permission dialog
        for _ in 0..<5 {
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                return try await fetchLocation()
            }
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        }
        throw LocationServiceError.permissionDenied
    }
}