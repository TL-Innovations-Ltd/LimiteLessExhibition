import SwiftUI

struct CurvedSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var onEditingChanged: (Bool) -> Void
    var isDisabled: Bool
    
    private let trackHeight: CGFloat = 10  // Increased track height
    private let knobSize: CGFloat = 36      // Increased knob size
    private let radius: CGFloat = 180        // Increased radius of the circular arc
    
    @State private var isDragging = false
    
    init(value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1, onEditingChanged: @escaping (Bool) -> Void = { _ in }, disabled: Bool = false) {
        self._value = value
        self.range = range
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.isDisabled = disabled
    }
    
    var body: some View {
        GeometryReader { geometry in
            let scale = min(1.0, geometry.size.width / (2 * radius + knobSize))
            ZStack(alignment: .center) {
                // Track background
                CircularTrackShape(radius: radius)
                    .stroke(Color.gray.opacity(0.2), lineWidth: trackHeight)
                    .frame(width: 2 * radius, height: radius)

                // Gradient track
                CircularTrackShape(radius: radius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.95, blue: 0.8),
                                Color.white,
                                Color(red: 0.8, green: 0.9, blue: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: trackHeight, lineCap: .round)
                    )
                    .frame(width: 2 * radius, height: radius)

                // Knob
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: knobSize + 8, height: knobSize + 8)
                        .blur(radius: 4)

                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: knobSize, height: knobSize)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Circle()
                        .fill(Color.white)
                        .frame(width: knobSize * 0.6, height: knobSize * 0.6)
                }
                .position(x: knobXPosition(), y: knobYPosition())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            if isDisabled { return }
                            if !isDragging {
                                isDragging = true
                                onEditingChanged(true)
                            }
                            updateValue(with: gesture.location)
                        }
                        .onEnded { _ in
                            if isDisabled { return }
                            isDragging = false
                            onEditingChanged(false)
                        }
                )

                // Tap-to-move the knob anywhere on the arc
                Color.clear
                    .contentShape(CircularTrackShape(radius: radius))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { drag in
                                if isDisabled { return }
                                updateValue(with: drag.location)
                                onEditingChanged(true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onEditingChanged(false)
                                }
                            }
                    )
            }
            .frame(width: 2 * radius, height: radius)
            .scaleEffect(scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .frame(height: radius + knobSize / 2)
    }
    
    // Calculate x position along the circular arc
    private func knobXPosition() -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let angle = percentage * .pi
        
        return radius + radius * cos(angle)
    }
    
    // Calculate y position along the circular arc
    private func knobYPosition() -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let angle = percentage * .pi
        
        return radius - radius * sin(angle)
    }
    
    // Update the value based on the drag position with improved accuracy
    private func updateValue(with location: CGPoint) {
        let cx = radius
        let cy = radius
        
        // Calculate vector from center to touch point
        let dx = location.x - cx
        let dy = cy - location.y  // Invert y-axis

        // Calculate angle in radians
        var angle = atan2(dy, dx)

        // Clamp angle safely within [0, π]
        angle = max(min(angle, .pi), 0)

        // Optional: Prevent sudden angle jump
        let lastPercentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let lastAngle = lastPercentage * .pi
        let angleDelta = abs(lastAngle - angle)

        if angleDelta > .pi / 1.5 {
            return // Ignore large unexpected jumps
        }

        // Convert angle to percentage of the slider range
        let percentage = angle / .pi
        var newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)

        // Apply stepping if needed
        if step > 0 {
            newValue = round(newValue / step) * step
        }

        // Clamp to range
        newValue = max(range.lowerBound, min(range.upperBound, newValue))

        // Update the value
        self.value = newValue
    }

}

// Custom shape for the circular track
struct CircularTrackShape: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let centerX = radius
        let centerY = radius
        
        path.addArc(
            center: CGPoint(x: centerX, y: centerY),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        return path
    }
}

// Preview provider for testing
struct CurvedSlider_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    // Wrapper to handle the state
    struct PreviewWrapper: View {
        @State private var sliderValue: Double = 50.0
        
        var body: some View {
            VStack {
                Text("Temperature Control")
                    .font(.headline)
                    .padding(.bottom, 20)
                
                CurvedSlider(value: $sliderValue, in: 0...100, step: 1)
                
                Text("Value: \(Int(sliderValue))")
                    .padding(.top, 20)
            }
            .padding(40)
            .background(Color(.systemBackground))
        }
    }
}
