import SwiftUI

struct CurvedSlider: View {
    @State private var brightness: Double = 50 // Initial brightness value

    var body: some View {
        ZStack {
            // Background lower half-circle
            Circle()
                .trim(from: 0.5, to: 1.0) // Creates the lower half-circle
                .stroke(Color.gray.opacity(0.5), lineWidth: 8)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(180)) // Keep orientation correct

            // Slider handle
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: getXOffset(), y: getYOffset())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            updateBrightness(from: value)
                        }
                )
        }
    }

    // Calculate the X offset for the slider knob position
    private func getXOffset() -> CGFloat {
        let angle = getAngle()
        return 100 * cos(angle) // 100 is half of the frame width
    }

    // Calculate the Y offset for the slider knob position (flipped for lower half-circle)
    private func getYOffset() -> CGFloat {
        let angle = getAngle()
        return 100 * sin(angle) // Adjust downward for the lower arc
    }

    // Convert brightness value (0-100) to angle in radians (for lower half-circle)
    private func getAngle() -> CGFloat {
        let percentage = brightness / 100
        return CGFloat.pi * (1 - percentage) // Maps 0-100 to 90° to -90°
    }

    // Update brightness based on drag position
    private func updateBrightness(from value: DragGesture.Value) {
        let dx = value.location.x - 100 // Offset from center
        let dy = value.location.y - 100
        let angle = atan2(dy, dx) // Get angle
        let normalizedAngle = (angle + .pi) / (2 * .pi) // Convert to 0-1 range
        brightness = max(0, min(100, (1 - normalizedAngle) * 100))
    }
}

#Preview {
    CurvedSlider()
}
