

import SwiftUI

struct SettingsView: View {
    @AppStorage("clockSize") private var clockSize: Double = 300

    var body: some View {
        Form {
            Slider(value: $clockSize, in: 100...500, step: 10) {
                Text("Clock Size")
            }
            Text("Current Size: \(Int(clockSize))")
        }
        .padding()
        .frame(width: 300, height: 150)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
