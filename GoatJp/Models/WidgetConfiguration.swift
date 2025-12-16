//
//  WidgetConfiguration.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation

/// Configuration for weather widget
struct WidgetConfiguration: Codable {
    /// Widget size option
    let size: WidgetSize

    /// Whether to use custom background image
    let useCustomBackground: Bool

    /// Location name override (nil for current location)
    let customLocation: String?

    /// Temperature unit
    let temperatureUnit: TemperatureUnit

    init(
        size: WidgetSize = .medium,
        useCustomBackground: Bool = false,
        customLocation: String? = nil,
        temperatureUnit: TemperatureUnit = .celsius
    ) {
        self.size = size
        self.useCustomBackground = useCustomBackground
        self.customLocation = customLocation
        self.temperatureUnit = temperatureUnit
    }
}

/// Widget size options
enum WidgetSize: String, CaseIterable, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }

    var description: String {
        switch self {
        case .small: return "Compact view"
        case .medium: return "Weather details"
        case .large: return "Full forecast"
        }
    }
}

/// Temperature unit options
enum TemperatureUnit: String, CaseIterable, Codable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

// MARK: - Default Configuration

extension WidgetConfiguration {
    static let `default` = WidgetConfiguration()
}