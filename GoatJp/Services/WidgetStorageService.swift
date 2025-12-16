//
//  WidgetStorageService.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation
import Combine

/// Service for storing and retrieving data shared between app and widget
final class WidgetStorageService: ObservableObject {
    private let userDefaults: UserDefaults
    private let appGroupID = "group.com.tom.tom.tom.GoatJp"

    /// Initialize with UserDefaults (injected for testing)
    init(userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.tom.tom.tom.GoatJp") ?? UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    /// Save current weather data for widget
    /// - Parameter weather: Weather data to save
    func saveWeather(_ weather: Weather) {
        do {
            let data = try JSONEncoder().encode(weather)
            userDefaults.set(data, forKey: "lastWeather")
        } catch {
            print("Failed to save weather data: \(error)")
        }
    }

    /// Retrieve saved weather data
    /// - Returns: Weather data if available, nil otherwise
    func loadWeather() -> Weather? {
        guard let data = userDefaults.data(forKey: "lastWeather") else { return nil }

        do {
            return try JSONDecoder().decode(Weather.self, from: data)
        } catch {
            print("Failed to load weather data: \(error)")
            return nil
        }
    }

    /// Save widget configuration
    /// - Parameter configuration: Widget configuration to save
    func saveWidgetConfiguration(_ configuration: WidgetConfiguration) {
        do {
            let data = try JSONEncoder().encode(configuration)
            userDefaults.set(data, forKey: "widgetConfiguration")
        } catch {
            print("Failed to save widget configuration: \(error)")
        }
    }

    /// Retrieve widget configuration
    /// - Returns: Widget configuration if available, default otherwise
    func loadWidgetConfiguration() -> WidgetConfiguration {
        guard let data = userDefaults.data(forKey: "widgetConfiguration"),
              let config = try? JSONDecoder().decode(WidgetConfiguration.self, from: data) else {
            return WidgetConfiguration.default
        }
        return config
    }

    /// Save custom background image data for widget
    /// - Parameter imageData: PNG data of the background image
    func saveBackgroundImage(_ imageData: Data) {
        userDefaults.set(imageData, forKey: "widgetBackgroundImage")
    }

    /// Retrieve saved background image data
    /// - Returns: Image data if available
    func loadBackgroundImage() -> Data? {
        return userDefaults.data(forKey: "widgetBackgroundImage")
    }

    /// Clear all widget data
    func clearAllData() {
        userDefaults.removeObject(forKey: "lastWeather")
        userDefaults.removeObject(forKey: "widgetConfiguration")
        userDefaults.removeObject(forKey: "widgetBackgroundImage")
    }
}