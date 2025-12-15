//
//  LocationServiceTests.swift
//  GoatJpTests
//
//  Created by Claude on 12/15/25.
//

import Foundation
import CoreLocation
import Testing
@testable import GoatJp

struct LocationServiceTests {

    @Test("LocationService should handle authorized permission correctly")
    func testAuthorizedLocationFetch() async throws {
        // Given
        let mockManager = MockCLLocationManager(
            authorizationStatus: .authorizedWhenInUse,
            location: CLLocation(latitude: 35.6762, longitude: 139.6503)
        )
        let sut = LocationService(locationManager: mockManager)

        // When
        let location = try await sut.requestLocation()

        // Then
        #expect(location.latitude == 35.6762)
        #expect(location.longitude == 139.6503)
    }

    @Test("LocationService should handle denied permission")
    func testDeniedPermission() async {
        // Given
        let mockManager = MockCLLocationManager(
            authorizationStatus: .denied,
            location: nil
        )
        let sut = LocationService(locationManager: mockManager)

        // When/Then
        await #expect(throws: LocationServiceError.permissionDenied.self) {
            try await sut.requestLocation()
        }
    }

    @Test("LocationService should handle restricted permission")
    func testRestrictedPermission() async {
        // Given
        let mockManager = MockCLLocationManager(
            authorizationStatus: .restricted,
            location: nil
        )
        let sut = LocationService(locationManager: mockManager)

        // When/Then
        await #expect(throws: LocationServiceError.permissionDenied.self) {
            try await sut.requestLocation()
        }
    }

    @Test("LocationService should prompt for permission when not determined")
    func testPromptForPermission() async throws {
        // Given
        let mockManager = MockCLLocationManager(
            authorizationStatus: .notDetermined,
            location: CLLocation(latitude: 34.6937, longitude: 135.5023)
        )
        let sut = LocationService(locationManager: mockManager)

        // When
        let location = try await sut.requestLocation()

        // Then
        #expect(mockManager.requestWhenInUseAuthorizationCalled == true)
        #expect(location.latitude == 34.6937)
        #expect(location.longitude == 135.5023)
    }

    @Test("LocationService should handle location errors")
    func testLocationError() async {
        // Given
        let mockManager = MockCLLocationManager(
            authorizationStatus: .authorizedWhenInUse,
            location: nil,
            error: LocationError.locatingFailed
        )
        let sut = LocationService(locationManager: mockManager)

        // When/Then
        await #expect(throws: LocationServiceError.locationUnavailable.self) {
            try await sut.requestLocation()
        }
    }

    @Test("LocationService should check current authorization status")
    func testAuthorizationStatus() {
        // Given
        let mockManager = MockCLLocationManager(
            authorizationStatus: .authorizedWhenInUse,
            location: nil
        )
        let sut = LocationService(locationManager: mockManager)

        // When
        let status = sut.authorizationStatus

        // Then
        #expect(status == .authorizedWhenInUse)
    }
}