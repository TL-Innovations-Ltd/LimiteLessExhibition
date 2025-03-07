import SwiftUI

struct PWM2LEDView: View {
    @State private var led1Brightness: Double = 75
    @State private var led2Brightness: Double = 50
    
    var body: some View {
        VStack(spacing: 30) {
            Text("PWM LED Controller")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
                .padding(.top)
            
            // LED 1 Control
            PendantLampControlView(
                title: "LED",
                brightness: $led1Brightness,
                color: .yellow
            )
            

            
            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
    }
}

struct PendantLampControlView: View {
    let title: String
    @Binding var brightness: Double
    let color: Color
    
    @State private var isGlowing = false
    
    let pwmIntensityObj = BluetoothManager() // Assuming you have this object defined elsewhere

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(.charlestonGreen)
            
            // Pendant Lamp
            ZStack {
                // Cord
                Rectangle()
                    .fill(Color.darkGray)
                    .frame(width: 2, height: 40)
                    .offset(y: -60)
                
                // Lamp Shade
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 12, height: 15)
                        .offset(y: -15)
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 40, height: 40)
                    // Bulb glow
                    Circle()
                        .fill(color.opacity(brightness/100))
                        .frame(width: 35, height: 35)
                        .scaleEffect(isGlowing ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: isGlowing
                        )
                    // Light glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(brightness / 150),
                                    color.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 70
                            )
                        )
                        .frame(width: 120, height: 120)
                        .opacity(brightness / 100)
                        .scaleEffect(isGlowing ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isGlowing
                        )
                        .mask(
                            Rectangle()
                                .frame(width: 120, height: 60) // Show only bottom half
                                .offset(y: 30) // Move the mask to cover the top
                        )

                    
                    
                    // Outer shade
                    LampShade()
                        .fill(Color.charlestonGreen)
                        .frame(width: 120, height: 60)
                        .offset(y: -30)
                    
                    // Inner shade highlight
                    LampShade()
                        .fill(Color.charlestonGreen.opacity(0.5))
                        .frame(width: 110, height: 55)
                        .offset(y: -30)
                }
                
                
                
                
            }
            .frame(height: 120)
            .onAppear {
                isGlowing = true
            }
            
            // Brightness Control Section
            VStack(spacing: 15) {
                        Text("Adjust Intensity")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Custom Slider with Warm White Gradient Background
                        ZStack {
                            // Gradient Background using #FFF3DA and #FAE9D5
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FFF3DA"),
                                        Color(hex: "#FAE9D5")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(height: 40)
                                .shadow(radius: 2)
                            
                            // Slider
                            Slider(value: $brightness, in: 0...100, step: 1, onEditingChanged: { _ in
                                                sendIntensity()
                                            })                                .frame(height: 40)
                                .accentColor(.white) // White slider knob
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 20)
                        
                        // Percentage indicators
                        HStack(spacing: 0) {
                            ForEach([0, 25, 50, 75, 100], id: \.self) { value in
                                Text("\(value)%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
            .padding(.top, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Function to send intensity value
    private func sendIntensity() {
            let intensityValue = Int(brightness)
            let intensityvalue2: Int = abs(intensityValue - 100)
            pwmIntensityObj.sendMessage("\(intensityValue) : \(intensityvalue2)") // Send integer intensity
        }
}

struct SliderControl: View {
    @Binding var value: Double
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 30)
                
                // Filled track
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow.opacity(0.7), .yellow]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, CGFloat(value / 100) * geometry.size.width), height: 30)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .overlay(
                        Circle()
                            .fill(Color.yellow)
                            .padding(8)
                    )
                    .position(
                        x: max(18, min(CGFloat(value / 100) * geometry.size.width, geometry.size.width - 18)),
                        y: geometry.size.height / 2
                    )
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isDragging)
                
                // Invisible drag area (full width for better interaction)
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                let newValue = min(max(0, Double(gesture.location.x / geometry.size.width * 100)), 100)
                                value = newValue
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
        }
    }
}

struct LampShade: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top width is narrower than bottom width for the lamp shade
        let topWidth = rect.width * 0.4
        let bottomWidth = rect.width
        
        // Define the four corners of the trapezoid
        let topLeft = CGPoint(x: rect.midX - topWidth/2, y: rect.minY)
        let topRight = CGPoint(x: rect.midX + topWidth/2, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.closeSubpath()
        
        return path
    }
}


#Preview {
    PWM2LEDView()
}

