//
//  HomeView.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import SwiftUI

/// Main home screen showing widget options and current weather
struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("Weather Widget")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Current Weather Preview
                if let weather = viewModel.currentWeather {
                    CurrentWeatherView(weather: weather)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 4)
                        )
                } else if viewModel.isLoading {
                    ProgressView("Loading weather...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)

                        Button("Retry", action: {
                            Task {
                                await viewModel.loadSampleWeather()
                            }
                        })
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }

                // Widget Options
                Text("Choose Your Widget")
                    .font(.headline)
                    .padding(.top)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    WidgetOptionCard(
                        title: "Small",
                        description: "Just the essentials",
                        icon: "rectangle",
                        color: .blue
                    ) {
                        // TODO: Navigate to widget configuration
                    }

                    WidgetOptionCard(
                        title: "Medium",
                        description: "Weather details",
                        icon: "rectangle.ratio",
                        color: .green
                    ) {
                        // TODO: Navigate to widget configuration
                    }

                    WidgetOptionCard(
                        title: "Large",
                        description: "Full forecast",
                        icon: "rectangle.stack",
                        color: .purple
                    ) {
                        // TODO: Navigate to widget configuration
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Settings Button
                NavigationLink(destination: WidgetSettingsView()) {
                    Text("Widget Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    // For now, load sample weather
                    // In production, you'd call loadWeatherForCurrentLocation()
                    await viewModel.loadSampleWeather()
                }
            }
        }
    }
}

/// Widget option card component
struct WidgetOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Current weather display component
struct CurrentWeatherView: View {
    let weather: Weather

    private var weatherDescription: String {
        switch weather.condition {
        case .sunny: return "Sunny"
        case .cloudy: return "Cloudy"
        case .sunBehindCloud: return "Partly Cloudy"
        case .raining: return "Raining"
        case .snow: return "Snow"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: weather.condition.iconName)
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text(weather.formattedTemperature)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)

                Text(weather.location)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(weatherDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    HomeView()
}