
import SwiftUI
import AppKit

@main
struct MyAnalogClockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            SettingsView()
        }

        // Add a menu bar extra for settings
        MenuBarExtra("MyAnalogClock", systemImage: "clock.fill") {
            SettingsLink {
                Text("Settings...")
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

