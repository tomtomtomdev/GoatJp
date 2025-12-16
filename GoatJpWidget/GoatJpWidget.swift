//
//  GoatJpWidget.swift
//  GoatJpWidget
//
//  Created by Claude on 12/15/25.
//

import WidgetKit
import SwiftUI

/// Provider for weather widget timeline
struct GoatJpProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weather: Weather.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weather: Weather.sample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Load weather data from shared storage
        let weather = loadWeatherFromStorage()

        // Create entries for the next minute
        let entries = [SimpleEntry(date: Date(), weather: weather)]

        // Update every minute as required
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))

        completion(timeline)
    }

    private func loadWeatherFromStorage() -> Weather {
        // Try to load from shared UserDefaults
        let shared = UserDefaults(suiteName: "group.com.tom.tom.tom.GoatJp")

        if let data = shared?.data(forKey: "lastWeather"),
           let weather = try? JSONDecoder().decode(Weather.self, from: data) {
            return weather
        }

        // Return sample data if no saved weather
        return Weather.sample
    }
}

/// Simple entry for the widget timeline
struct SimpleEntry: TimelineEntry {
    let date: Date
    let weather: Weather
}

/// Widget configuration view
struct GoatJpWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        let backgroundImage = loadBackgroundImage()
        switch family {
        case .systemSmall:
            SmallWeatherWidget(weather: entry.weather, backgroundImage: backgroundImage)
        case .systemMedium:
            MediumWeatherWidget(weather: entry.weather, backgroundImage: backgroundImage)
        case .systemLarge:
            LargeWeatherWidget(weather: entry.weather, backgroundImage: backgroundImage)
        @unknown default:
            SmallWeatherWidget(weather: entry.weather, backgroundImage: backgroundImage)
        }
    }

    private func loadBackgroundImage() -> UIImage? {
        let shared = UserDefaults(suiteName: "group.com.tom.tom.tom.GoatJp")
        if let imageData = shared?.data(forKey: "widgetBackgroundImage") {
            return UIImage(data: imageData)
        }
        return nil
    }
}

/// Widget configuration
struct GoatJpWidget: Widget {
    let kind: String = "GoatJpWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GoatJpProvider()) { entry in
            GoatJpWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weather Widget")
        .description("Shows current weather information")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/// Widget bundle
@main
struct GoatJpWidgetBundle: WidgetBundle {
    var body: some Widget {
        GoatJpWidget()
    }
}

// MARK: - Widget Views

/// Small weather widget (icon + temperature)
struct SmallWeatherWidget: View {
    let weather: Weather
    let backgroundImage: UIImage?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: weather.condition.iconName)
                .font(.system(size: 30))
                .foregroundColor(.yellow)

            Text(weather.formattedTemperature)
                .font(.title)
                .fontWeight(.bold)

            Text(weather.location)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(Color.black.opacity(0.3))
            } else {
                LinearGradient(
                    gradient: Gradient(colors: backgroundGradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var backgroundGradient: [Color] {
        switch weather.condition {
        case .sunny:
            return [.orange, .yellow]
        case .cloudy:
            return [.gray, .blue]
        case .sunBehindCloud:
            return [.orange, .gray]
        case .raining:
            return [.blue, .gray]
        case .snow:
            return [.white, .blue]
        }
    }
}

/// Medium weather widget (temperature + details)
struct MediumWeatherWidget: View {
    let weather: Weather
    let backgroundImage: UIImage?

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Icon and temperature
            VStack(spacing: 8) {
                Image(systemName: weather.condition.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)

                Text(weather.formattedTemperature)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            // Right side - Location and condition
            VStack(alignment: .leading, spacing: 4) {
                Text(weather.location)
                    .font(.headline)

                Text(weatherDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Updated: \(timeString)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: backgroundGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var weatherDescription: String {
        switch weather.condition {
        case .sunny: return "Sunny"
        case .cloudy: return "Cloudy"
        case .sunBehindCloud: return "Partly Cloudy"
        case .raining: return "Raining"
        case .snow: return "Snow"
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: weather.timestamp)
    }

    private var backgroundGradient: [Color] {
        switch weather.condition {
        case .sunny:
            return [.orange, .yellow]
        case .cloudy:
            return [.gray, .blue]
        case .sunBehindCloud:
            return [.orange, .gray]
        case .raining:
            return [.blue, .gray]
        case .snow:
            return [.white, .blue]
        }
    }
}

/// Large weather widget (full forecast)
struct LargeWeatherWidget: View {
    let weather: Weather
    let backgroundImage: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(weather.location)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(weatherDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: weather.condition.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
            }

            // Temperature
            Text(weather.formattedTemperature)
                .font(.system(size: 60, weight: .thin))

            // Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Feels like")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(feelsLike)
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timeString)
                        .font(.headline)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: backgroundGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var weatherDescription: String {
        switch weather.condition {
        case .sunny: return "Sunny"
        case .cloudy: return "Cloudy"
        case .sunBehindCloud: return "Partly Cloudy"
        case .raining: return "Raining"
        case .snow: return "Snow"
        }
    }

    private var feelsLike: String {
        "\(Int(weather.temperature.rounded()))°C"
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: weather.timestamp)
    }

    private var backgroundGradient: [Color] {
        switch weather.condition {
        case .sunny:
            return [.orange, .yellow]
        case .cloudy:
            return [.gray, .blue]
        case .sunBehindCloud:
            return [.orange, .gray]
        case .raining:
            return [.blue, .gray]
        case .snow:
            return [.white, .blue]
        }
    }
}

// MARK: - Weather Sample Extension

extension Weather {
    static let sample = Weather(
        temperature: 22.5,
        condition: .sunny,
        location: "Tokyo",
        timestamp: Date()
    )
}