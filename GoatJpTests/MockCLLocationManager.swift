//
//  MockCLLocationManager.swift
//  GoatJpTests
//
//  Created by Claude on 12/15/25.
//

import Foundation
import CoreLocation
@testable import GoatJp

/// Mock CLLocationManager for testing
final class MockCLLocationManager: CLLocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus
    var location: CLLocation?
    var error: Error?
    var requestWhenInUseAuthorizationCalled = false

    init(authorizationStatus: CLAuthorizationStatus, location: CLLocation?, error: Error? = nil) {
        self.authorizationStatus = authorizationStatus
        self.location = location
        self.error = error
    }

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
        // Simulate permission granted
        if authorizationStatus == .notDetermined {
            authorizationStatus = .authorizedWhenInUse
        }
    }

    func requestLocation() async throws -> CLLocation {
        if let error = error {
            throw error
        }

        guard let location = location else {
            throw LocationError.locatingFailed
        }

        return location
    }
}

