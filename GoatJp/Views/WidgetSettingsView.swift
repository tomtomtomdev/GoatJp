//
//  WidgetSettingsView.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import SwiftUI
import PhotosUI

/// Widget settings screen for configuring widgets
struct WidgetSettingsView: View {
    @State private var configuration = WidgetConfiguration.default
    @State private var selectedItem: PhotosPickerItem?
    @State private var backgroundImage: UIImage?
    @StateObject private var storageService = WidgetStorageService()

    var body: some View {
        NavigationView {
            Form {
                // Widget Size Section
                Section("Widget Size") {
                    ForEach(WidgetSize.allCases, id: \.self) { size in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(size.displayName)
                                    .font(.headline)
                                Text(size.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if configuration.size == size {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            configuration = WidgetConfiguration(
                                size: size,
                                useCustomBackground: configuration.useCustomBackground,
                                customLocation: configuration.customLocation,
                                temperatureUnit: configuration.temperatureUnit
                            )
                        }
                    }
                }

                // Temperature Unit Section
                Section("Temperature Unit") {
                    Picker("Unit", selection: Binding(
                        get: { configuration.temperatureUnit },
                        set: { newValue in
                            configuration = WidgetConfiguration(
                                size: configuration.size,
                                useCustomBackground: configuration.useCustomBackground,
                                customLocation: configuration.customLocation,
                                temperatureUnit: newValue
                            )
                        }
                    )) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit.symbol).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Custom Background Section
                Section("Custom Background") {
                    Toggle("Use Custom Background", isOn: Binding(
                        get: { configuration.useCustomBackground },
                        set: { newValue in
                            configuration = WidgetConfiguration(
                                size: configuration.size,
                                useCustomBackground: newValue,
                                customLocation: configuration.customLocation,
                                temperatureUnit: configuration.temperatureUnit
                            )
                        }
                    ))

                    if configuration.useCustomBackground {
                        VStack(alignment: .leading, spacing: 8) {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Label("Select Photo", systemImage: "photo")
                            }
                            .buttonStyle(.bordered)

                            if let backgroundImage = backgroundImage {
                                Image(uiImage: backgroundImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // Save Button
                Section {
                    Button("Save Configuration") {
                        saveConfiguration()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Widget Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    backgroundImage = image
                    storageService.saveBackgroundImage(data)
                }
            }
        }
    }

    private func saveConfiguration() {
        storageService.saveWidgetConfiguration(configuration)
    }
}

#Preview {
    WidgetSettingsView()
}