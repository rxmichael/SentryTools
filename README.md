# SentryTools - iOS Crash & Performance Monitoring

## 🚀 Features

### 📊 Thread Monitoring
- **Main Thread Hang Detection**: Monitors main thread responsiveness and detects UI freezes
- **Configurable Thresholds**: Set custom timeout values for hang detection
- **Background Monitoring**: Uses dedicated threads to avoid interference with app performance
- **Application State Awareness**: Automatically pauses monitoring when app goes to background

### 💥 Crash Reporting
- **Signal Handler**: Catches SIGSEGV, SIGABRT, SIGFPE, SIGILL and other fatal signals
- **Exception Handler**: Captures NSException crashes with full stack traces
- **Crash Types Supported**:
  - Memory errors (segmentation faults, use-after-free)
  - Signal-based crashes (illegal instructions, floating point errors)
  - NSException crashes (array bounds, invalid arguments)
  - Swift runtime errors

## 📖 Usage

### Basic Setup

```swift
import SwiftUI
import SentryTools

@main
struct MyApp: App {
    @State private var threadMonitor = ThreadMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(threadMonitor)
                .onAppear {
                    // Initialize crash reporting
                    CrashReporter.shared.initialize()
                    
                    // Start thread monitoring
                    Task {
                        await threadMonitor.startMonitoring()
                    }
                }
        }
    }
}
```

### Thread Monitoring

```swift
// Basic usage with default settings (4 second threshold)
let monitor = ThreadMonitor()
await monitor.startMonitoring()

// Custom configuration
let monitor = ThreadMonitor(
    notificationCenter: .default,
    threshold: 2.0  // 2 second hang threshold
)
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
