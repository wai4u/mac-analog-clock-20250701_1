
import SwiftUI
import AppKit // Import AppKit for NSWindow

// Helper struct to access the NSWindow
struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var window: NSWindow? // State to hold the NSWindow
    @State private var isHovering: Bool = false // For opacity on hover
    @AppStorage("clockSize") private var clockSize: Double = 300 // For resizable clock

    var body: some View {
        VStack {
            AnalogClockView(currentTime: currentTime)
                .frame(width: clockSize, height: clockSize) // Use clockSize
        }
        .background(WindowAccessor(window: $window)) // Attach WindowAccessor
        .background(.clear) // Ensure SwiftUI view background is clear
        .ignoresSafeArea() // Make the view ignore safe area insets
        .onAppear(perform: setupTimer)
        .onAppear {
            // Apply window properties when the view appears
            if let window = window {
                // Set styleMask first
                window.styleMask = [.borderless, .resizable] // Set styleMask to borderless and resizable
                
                window.isOpaque = false
                window.backgroundColor = .clear
                // window.titlebarAppearsTransparent = true // Not needed for borderless
                // window.titleVisibility = .hidden // Not needed for borderless
                // window.standardWindowButton(.closeButton)?.isHidden = true // Not needed for borderless
                // window.standardWindowButton(.miniaturizeButton)?.isHidden = true // Not needed for borderless
                // window.standardWindowButton(.zoomButton)?.isHidden = true // Not needed for borderless
                window.level = .floating // Always on top
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Allow it to appear in all spaces and full screen
                window.alphaValue = 1.0 // Initial opaque
                window.hasShadow = false // Disable window shadow

                // Ensure the content view has a transparent layer
                if let contentView = window.contentView {
                    contentView.wantsLayer = true
                    contentView.layer?.backgroundColor = NSColor.clear.cgColor
                }
            }
        }
        .onHover { hovering in
            isHovering = hovering
            if let window = window {
                window.alphaValue = hovering ? 0.0 : 1.0 // Transparent on hover, opaque otherwise
            }
        }
    }

    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
        }
    }
}

struct AnalogClockView: View {
    var currentTime: Date

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2

            // Define thresholds for hiding numbers
            let hideNumbersThreshold: CGFloat = 75 // Radius below which numbers are hidden

            // Dynamic indicator lengths and offsets with minimums
            let minIndicatorLength: CGFloat = 3.0 // Minimum length for 1-min indicators
            let minHourIndicatorLength: CGFloat = 6.0 // Minimum length for 5-min indicators
            let minIndicatorWidth: CGFloat = 1.0 // Minimum width for 1-min indicators
            let minHourIndicatorWidth: CGFloat = 2.0 // Minimum width for 5-min indicators

            // Scale factor for indicators when clock is small
            let smallClockIndicatorScale: CGFloat = 2.7 // Adjust this value as needed

            let scaledIndicatorLength = radius * 0.05 * (radius < hideNumbersThreshold ? smallClockIndicatorScale : 1.0)
            let scaledHourIndicatorLength = radius * 0.08 * (radius < hideNumbersThreshold ? smallClockIndicatorScale : 1.0)
            let scaledIndicatorWidth = radius * 0.005 * (radius < hideNumbersThreshold ? smallClockIndicatorScale : 1.0)
            let scaledHourIndicatorWidth = radius * 0.01 * (radius < hideNumbersThreshold ? smallClockIndicatorScale : 1.0)

            let indicatorLength = max(scaledIndicatorLength, minIndicatorLength)
            let hourIndicatorLength = max(scaledHourIndicatorLength, minHourIndicatorLength)

            let indicatorWidth = max(scaledIndicatorWidth, minIndicatorWidth)
            let hourIndicatorWidth = max(scaledHourIndicatorWidth, minHourIndicatorWidth)

            let dialLineWidth = max(radius * 0.015, 1.0) // Clock Dial line width

            let numberOffset = radius * 0.75
            let fontSize = radius * 0.15

            ZStack {
                // Clock Dial
                Circle()
                    .stroke(lineWidth: dialLineWidth) // Dynamic line width with minimum
                    .foregroundColor(.primary)

                // Minute and Hour Indicators
                ForEach(0..<60) { i in
                    let currentIndicatorLength = i % 5 == 0 ? hourIndicatorLength : indicatorLength
                    Rectangle()
                        .fill(i % 5 == 0 ? Color.primary : Color.gray)
                        .frame(width: i % 5 == 0 ? hourIndicatorWidth : indicatorWidth, // Dynamic width with minimum
                               height: currentIndicatorLength) // Dynamic height with minimum
                        .offset(y: -(radius - dialLineWidth / 2 - currentIndicatorLength / 2))
                        .rotationEffect(.degrees(Double(i) * 6))
                }

                // Hour Numbers (conditionally hidden)
                if radius >= hideNumbersThreshold {
                    ForEach(1..<13) { i in
                        Text("\(i)")
                            .font(.system(size: fontSize)) // Dynamic font size
                            .rotationEffect(.degrees(-Double(i) * 30)) // Counter-rotate text to keep it upright
                            .offset(y: -numberOffset) // Dynamic offset
                            .rotationEffect(.degrees(Double(i) * 30)) // Rotate the number to its position
                    }
                }

                // Hour Hand
                Hand(angle: hourAngle(), lengthRatio: 0.5, width: max(radius * 0.02, 2.0), color: .blue) // Dynamic width with minimum

                // Minute Hand
                Hand(angle: minuteAngle(), lengthRatio: 0.7, width: max(radius * 0.015, 1.5), color: .green) // Dynamic width with minimum

                // Second Hand
                Hand(angle: secondAngle(), lengthRatio: 0.8, width: max(radius * 0.007, 0.7), color: .red) // Dynamic width with minimum

                // Center Pin
                Circle()
                    .frame(width: max(radius * 0.03, 3.0), height: max(radius * 0.03, 3.0)) // Dynamic size with minimum
                    .foregroundColor(.primary)
            }
        }
    }

    private func hourAngle() -> Angle {
        let hour = Calendar.current.component(.hour, from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        let hourAngle = (Double(displayHour) / 12) * 360
        let minuteFraction = (Double(minute) / 60) * 30 // Each minute moves hour hand by 0.5 degrees (30/60)
        return Angle(degrees: hourAngle + minuteFraction)
    }

    private func minuteAngle() -> Angle {
        let minute = Calendar.current.component(.minute, from: currentTime)
        let second = Calendar.current.component(.second, from: currentTime)
        let minuteAngle = (Double(minute) / 60) * 360
        let secondFraction = (Double(second) / 60) * 6 // Each second moves minute hand by 0.1 degrees (6/60)
        return Angle(degrees: minuteAngle + secondFraction)
    }

    private func secondAngle() -> Angle {
        let second = Calendar.current.component(.second, from: currentTime)
        return Angle(degrees: (Double(second) / 60) * 360)
    }
}

struct Hand: View {
    var angle: Angle
    var lengthRatio: CGFloat
    var width: CGFloat
    var color: Color

    var body: some View {
        GeometryReader {
            geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let handLength = radius * lengthRatio

            Path { path in
                path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)) // Start at center
                path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2 - handLength)) // Draw line upwards
            }
            .stroke(color, lineWidth: width)
            .rotationEffect(Angle(degrees: angle.degrees)) // Apply rotation directly
        }
    }
}


