
import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()

    var body: some View {
        VStack {
            AnalogClockView(currentTime: currentTime)
                .frame(width: 300, height: 300)
                .padding()

            Text("Current Time: \(currentTime, formatter: Self.timeFormatter)")
                .font(.title2)
                .padding(.bottom)
        }
        .onAppear(perform: setupTimer)
        .frame(minWidth: 400, minHeight: 450)
    }

    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
}

struct AnalogClockView: View {
    var currentTime: Date

    var body: some View {
        ZStack {
            // Clock Dial
            Circle()
                .stroke(lineWidth: 5)
                .foregroundColor(.primary)

            // Minute and Hour Indicators
            ForEach(0..<60) { i in
                Rectangle()
                    .fill(i % 5 == 0 ? Color.primary : Color.gray)
                    .frame(width: i % 5 == 0 ? 3 : 1, height: i % 5 == 0 ? 15 : 7)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(i) * 6))
            }

            // Hour Numbers
            ForEach(1..<13) { i in
                Text("\(i)")
                    .font(.title2)
                    .rotationEffect(.degrees(-Double(i) * 30)) // Counter-rotate text to keep it upright
                    .offset(y: -100) // Adjust this value to move numbers closer/further from center
                    .rotationEffect(.degrees(Double(i) * 30)) // Rotate the number to its position
            }

            // Hour Hand
            Hand(angle: hourAngle(), lengthRatio: 0.5, width: 6, color: .blue)

            // Minute Hand
            Hand(angle: minuteAngle(), lengthRatio: 0.7, width: 4, color: .green)

            // Second Hand
            Hand(angle: secondAngle(), lengthRatio: 0.8, width: 2, color: .red)

            // Center Pin
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(.primary)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
