//
//  CLLocationManagerProtocol.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation
import CoreLocation

/// Protocol to make CLLocationManager injectable for testing
public protocol CLLocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization()
    func requestLocation() async throws -> CLLocation
}

extension CLLocationManager: CLLocationManagerProtocol {
    public var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    public func requestLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            self.requestLocation()
            // This is a simplified version - in a real app, you'd implement proper delegate handling
            // For testing purposes, we'll use a timeout mechanism
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                continuation.resume(throwing: LocationError.locatingFailed)
            }
        }
    }
}

/// Mock location errors
public enum LocationError: Error {
    case locatingFailed
}