//
//  Weather.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation

/// Represents weather information for a specific location
struct Weather {
    /// Temperature in Celsius
    let temperature: Double

    /// Weather condition
    let condition: Condition

    /// Location name
    let location: String

    /// When the weather data was last updated
    let timestamp: Date

    /// Weather condition types
    enum Condition: CaseIterable {
        case sunny
        case cloudy
        case sunBehindCloud
        case raining
        case snow

        /// SF Symbol icon name for the condition
        var iconName: String {
            switch self {
            case .sunny:
                return "sun.max.fill"
            case .cloudy:
                return "cloud.fill"
            case .sunBehindCloud:
                return "cloud.sun.fill"
            case .raining:
                return "cloud.rain.fill"
            case .snow:
                return "snow"
            }
        }
    }

    /// Formatted temperature string (e.g., "25°C")
    var formattedTemperature: String {
        "\(Int(temperature.rounded()))°C"
    }

    /// Determines if temperature is extreme (hot > 33°C or cold < -5°C)
    var isExtreme: Bool {
        temperature > 33.0 || temperature < -5.0
    }
}