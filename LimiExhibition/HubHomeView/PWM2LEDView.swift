import SwiftUI


struct PWM2LEDView: View {
    let hub: Hub
    @State private var led1warmCold: Double = 50
    @State private var led2Brightness: Double = 50
    @ObservedObject var sharedDevice = SharedDevice.shared
    
    @State private var showPopup = false
    @State private var navigateToHome = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Bela Lamp")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
                .padding(.top)
            
            // LED 1 Control
            PendantLampControlView(
                title: "LED",
                warmCold: $led1warmCold,
                brightness: $led2Brightness,
                color: .emerald,
                hub: hub
            )
            
            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
        .onChange(of: sharedDevice.connectedDevice) { oldValue, newValue in
            if newValue == nil {
                showPopup = true // Show alert if the device is disconnected
            }
        }
        .alert("Device Disconnected", isPresented: $showPopup) {
            Button("Go to Home") {
                navigateToHome = true
            }
        } message: {
            Text("Your device has been disconnected.")
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
    }
}



struct PendantLampControlView: View {
    let title: String
    @Binding var warmCold: Double
    @Binding var brightness: Double
    let color: Color
    let hub: Hub

    @AppStorage("lampState") private var isOn: Bool = false
    @State private var isGlowing = false
    @StateObject private var pwmIntensityObj = BluetoothManager.shared
    @State private var showAlert = false  // State to show alert
        
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(.charlestonGreen)
                    .frame(alignment: .center)
                Spacer()
                Toggle(isOn: $isOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .emerald))
                    .onChange(of: isOn) {
                        sendLampState()
                    }
            }
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
                        .fill(color.opacity(warmCold / 100))
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
                                    color.opacity(warmCold / 150),
                                    color.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 70
                            )
                        )
                        .frame(width: 120, height: 120)
                        .opacity(warmCold / 100)
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

            // warmCold Control Section
            VStack(spacing: 15) {
                Text("Adjust Color")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Custom Slider with Warm White Gradient Background
                ZStack {
                    // Gradient Background using #FFF3DA and #FAE9D5
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#FFFFFF"),
                                Color(hex: "#FAE9D5")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(height: 40)
                        .shadow(radius: 2)
                    
                    // Slider
                    Slider(value: $warmCold, in: 0...100, step: 1, onEditingChanged: { isEditing in
                        if isEditing {
                            sendHapticFeedback() // Trigger haptic feedback
                        }
                        sendColor()
                    })
                    .onChange(of: warmCold) {
                        sendHapticFeedback() // Continuous feedback as the slider moves
                    }
                    .frame(height: 40)
                    .accentColor(.white) // White slider knob
                    .padding(.horizontal, 20)
                    .disabled(!isOn)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            
            VStack(spacing: 15) {
                Text("Adjust Brightness")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Custom Slider with Warm White Gradient Background
                ZStack {
                    // Gradient Background using #FFF3DA and #FAE9D5
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(1), Color.clear]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .frame(height: 40)
                        .shadow(radius: 2)
                    // Slider
                    Slider(value: $brightness, in: 0...100, step: 1, onEditingChanged: { isEditing in
                        if isEditing {
                            sendHapticFeedback() // Trigger haptic feedback
                        }
                        sendIntensity()
                    })
                    .onChange(of: brightness) {
                        sendHapticFeedback()
                    }
                    .frame(height: 40)
                    .accentColor(.white) // White slider knob
                    .padding(.horizontal, 20)
                    .disabled(!isOn)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Device Disconnected"), message: Text("Please reconnect your device."), dismissButton: .default(Text("OK")))
        }
        .onChange(of: pwmIntensityObj.isConnected) { _, newValue in
            if !newValue {
                showAlert = true
            }
        }
    }

    func sendHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    // Function to send lamp state
    private func sendLampState() {
        DispatchQueue.main.async {
            if isOn {
                sendColor()
            } else {
                sendOff()
            }
        }
    }
    
    
    private func sendOn() {
        let btyeArray : [UInt8] = [0x00, 0x00, 0x00, 0x00]
        sendMessage(hub: hub, message: btyeArray)
    }
    
    private func sendOff() {
        let btyeArray : [UInt8] = [0x00, 0x00, 0x00, 0x00]
        sendMessage(hub: hub, message: btyeArray)

    }
    
    // Function to send intensity value
    private func sendColor() {
        let intensityValue = Int(warmCold)
        let intensityValue2: Int = abs(intensityValue - 100)
        let brightnessValue = Int(brightness)
        
        let byteArray: [UInt8] = [
            0x01,
            UInt8(intensityValue & 0xFF),
            UInt8(intensityValue2 & 0xFF),
            UInt8(brightnessValue & 0xFF)
        ]
        
        let hexString = byteArray.map { String(format: "0x%02X", $0) }.joined(separator: ", ")
        
        print("Sending Data: \(hexString)") // Debug output
        
        sendMessage(hub: hub, message: byteArray)
    }

    // Function to send intensity value
    private func sendIntensity() {
        let brightnessValue = Int(brightness)
        let intensityValue = Int(warmCold)
        let intensityValue2: Int = abs(intensityValue - 100)
        
        let byteArray: [UInt8] = [
            0x01,
            UInt8(intensityValue & 0xFF),
            UInt8(intensityValue2 & 0xFF),
            UInt8(brightnessValue & 0xFF)
        ]
        
        let hexString = byteArray.map { String(format: "0x%02X", $0) }.joined(separator: ", ")
        print("\(hexString)")
        sendMessage(hub: hub, message: byteArray)
    }

    private func sendMessage(hub: Hub, message: [UInt8]) {
        if let device = pwmIntensityObj.connectedDevices[hub.id] {
            let data = Data(message)
            pwmIntensityObj.sendMessageToDevice(to: hub.id, message: [UInt8](data)) // Convert Data back to [UInt8]

        } else {
            print("Device not connected")
        }
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
    PWM2LEDView(hub: Hub(name: "Test Hub"))
}
