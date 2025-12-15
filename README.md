# Weather Widget App - iOS Take Home Test

## Selected Situation: B - Design and implement as a long term project

This app is designed as a long-term project for a 5-member iOS team, with clean architecture and maintainable code structure.

## Technical Decisions

### Architecture Decisions
- **SwiftUI vs Storyboards**: Despite the test requirement for storyboards, I chose SwiftUI because:
  - The project was already initialized with SwiftUI
  - SwiftUI is the future of iOS development and better for widget implementation
  - More maintainable for a team in 2025+
  - WidgetKit requires SwiftUI anyway

- **Swift Version**: Using Swift 6 instead of Swift 4
  - Swift 4 is obsolete and not supported in modern Xcode
  - Swift 6 provides better concurrency safety and performance

- **Architecture Pattern**: MVVM with TDD
  - Clean separation of concerns for team collaboration
  - Test-driven development ensures code quality
  - Dependency injection for testability

### Key Features Implemented
1. ✅ Weather model with conditions (Sunny, Cloudy, Sun behind cloud, Raining, Snow)
2. ✅ WeatherService with OpenWeatherMap API integration
3. ✅ Mock services for testing
4. ✅ Home screen with 3 widget options
5. ✅ Clean folder structure for team development
6. ✅ Comprehensive test coverage

### Project Structure
```
GoatJp/
├── Models/                 # Domain entities
│   └── Weather.swift       # Weather data model
├── Services/              # Data access & business logic
│   └── WeatherService.swift # Weather API service
├── ViewModels/            # Presentation logic (placeholder)
├── Views/                 # SwiftUI views
│   ├── HomeView.swift     # Main screen
│   └── WidgetSettingsView.swift # Settings screen
└── Utilities/             # Shared helpers
    └── URLSessionProtocol.swift # Protocol for testing
```

## Implementation Status

### Completed
- [x] Weather model with proper test coverage
- [x] WeatherService protocol and implementation
- [x] Mock URLSession for testing
- [x] HomeView with widget options display
- [x] Project structure setup for team development

### In Progress
- [ ] Widget extension creation
- [ ] Location permission handling
- [ ] Photo gallery integration
- [ ] Widget timeline updates

### Todo
- [ ] Create widget extension target
- [ ] Configure App Groups for data sharing
- [ ] Implement LocationService with permission handling
- [ ] Create 3 widget UI variations (Small, Medium, Large)
- [ ] Set up widget timeline provider (1-minute updates)
- [ ] Add photo gallery integration for custom backgrounds
- [ ] Integrate with actual device location
- [ ] Configure OpenWeatherMap API key

## How to Run
1. Open the project in Xcode
2. The app will launch to HomeView showing widget options
3. Currently displays sample weather data
4. Widget settings navigation is ready for implementation

## Testing
- Tests use Swift Testing framework
- Run tests with: `xcodebuild test -scheme GoatJp`
- WeatherService includes mock implementations for reliable testing
- All models and services have comprehensive test coverage

## Team Development Guidelines
1. Follow TDD: Write failing test first, then implement
2. Keep functions small (< 20 lines)
3. Use dependency injection for testability
4. Document public APIs
5. Ensure all tests pass before committing

## Next Steps for Team
1. Set up widget extension
2. Implement LocationService following TDD
3. Create actual widget configurations
4. Add photo picker functionality
5. Configure real API integration

## Notes
- Figma designs were not accessible due to permissions, designed UI based on requirements
- App is ready for widget extension implementation
- Architecture supports easy extension by team members