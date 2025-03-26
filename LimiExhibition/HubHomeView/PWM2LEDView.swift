import SwiftUI

struct PWM2LEDView: View {
    let hub: Hub
    @AppStorage("led1WarmCold") private var led1warmCold: Double = 50
    @AppStorage("led2Brightness") private var led2Brightness: Double = 50
    @AppStorage("lampPWM") private var isOn: Bool = false
    @ObservedObject var sharedDevice = SharedDevice.shared
    @State private var isAIModeActive = false
    @State private var backgroundImage: String = "name3"
    @State private var showPopup = false
    @State private var navigateToHome = false
    @State private var wireHeight: CGFloat = 300 // Initial height of the wire image
    @ObservedObject private var storeHistory = StoreHistory() // Add this line

    var body: some View {
        ZStack{
            // Background image
//            Image(backgroundImage)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .blur(radius: 5) // Adjust the blur radius as needed (1-20)
//                .edgesIgnoringSafeArea(.all)

            ElegantGradientBackgroundView()

            VStack{
                Image("wire")
                    .resizable()
                    .frame(width: 50, height: wireHeight)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                        }
                    }
                
                ZStack {
                    
                    Ellipse()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: led1warmCold <= 50 ? "#FFFFFF" : "#FFE4B5"),
                                Color(hex: led1warmCold <= 50 ? "#FFFFFF" : "#FFE4B5").opacity(0.6)
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        ))
                        .frame(width: 180, height: 45)
                        .opacity(led2Brightness/100)
                        .blur(radius: 15)
                        .padding(.top, 160)
                    
                    Image("ceilingHorizaontal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            }
                        }
                        .shadow(color:.white, radius: 4)
                    Ellipse()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: led1warmCold <= 50 ? "#FFFFFF" : "#FFE4B5"),
                                Color(hex: led1warmCold <= 50 ? "#FFFFFF" : "#FFE4B5").opacity(0.4)
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        ))
                        .frame(width: 120, height: 45)
                        .opacity(isOn ? led2Brightness / 100 : 0)
                        .blur(radius: 12)
                        .padding(.top, 100)
                }
                .padding(.top, -50)

            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 125) // Adjust this value to fine-tune the position
            
            VStack(spacing: 30) {
                // LED 1 Control
                PendantLampControlView(
                    title: "Bela Lampe",
                    warmCold: $led1warmCold,
                    brightness: $led2Brightness,
                    color: .emerald,
                    hub: hub,
                    wireHeight: $wireHeight,
                    backgroundImage: $backgroundImage, // Pass the wireHeight binding
                    isOn: $isOn, // Pass the isOn binding
                    isAIModeActive: $isAIModeActive // Pass this binding

                )
            }
            .padding()
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
            }
            message: {
                Text("Your device has been disconnected.")
            }
            .fullScreenCover(isPresented: $navigateToHome) {
                HomeView()
            }
            .allowsHitTesting(!isAIModeActive) // Disable controls during AI mode
            .opacity(isAIModeActive ? 0.5 : 1.0) // Fade controls during AI mode
            
            if storeHistory.isQueueFull {
                AIButtonView(hub: hub)
                    .onChange(of: isAIModeActive) { _, newValue in
                        withAnimation {
                            self.isAIModeActive = newValue
                        }
                    }
            }

        }
    }
}

struct PendantLampControlView: View {
    let title: String
    @Binding var warmCold: Double
    @Binding var brightness: Double
    let color: Color
    let hub: Hub
    @Binding var wireHeight: CGFloat // Add wireHeight binding
    @Binding var backgroundImage: String
    @Binding var isOn: Bool // Add this line
    @Binding var isAIModeActive: Bool

    @State private var isEditingSliderBrightness = false
    @State private var isEditingSliderColor = false

    @ObservedObject var storeHistory = StoreHistory()

    @State private var isGlowing = false
    @StateObject private var pwmIntensityObj = BluetoothManager.shared
    @State private var showAlert = false  // State to show alert
    @State private var showAIButton = false

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.alabaster)
                    .padding(.top)
                    .shadow(color:.white, radius: 6)
                Spacer()
                Toggle(isOn: $isOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .emerald))
                    .onChange(of: isOn) { oldValue, newValue in
                        
                        withAnimation {
                            wireHeight = newValue ? 500 : 300 // Animate height change
                        }
                        sendLampState()
                    }
            }


            
            Spacer()
            VStack{
                VStack(spacing: 15) {
                    Text("\(Int(brightness))%")
                        .font(.subheadline)
                        .foregroundColor(.charlestonGreen)
                    // Custom Slider with Warm White Gradient Background
                    ZStack {
                        Slider(value: $brightness, in: 0...100, step: 1, onEditingChanged: { isEditing in
                            if isEditing {
                                isEditingSliderBrightness = true
                                sendHapticFeedback() // Trigger haptic feedback
                            } else if isEditingSliderBrightness {
                                sendIntensity() // Only call when slider is released
                                isEditingSliderBrightness = false
                            }
                        })
                        .frame(height: 5)
                        .accentColor(.white) // White slider knob
                        .padding(.horizontal, 10)
                        .disabled(!isOn)
                    }
                    
                }
                .padding(.top, 20)
                .onChange(of: brightness) {
                    sendHapticFeedback() // Continuous feedback as the slider moves
                }
                .padding(.horizontal, 20)
                // warmCold Control Section
                VStack(spacing: 15) {
                    Text("Adjust Color")
                        .font(.subheadline)
                        .foregroundColor(.charlestonGreen)
                    
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
                        Slider(value: $warmCold, in: 0...100, step: 1, onEditingChanged: {
                            isEditing in
                            if isEditing {
                                isEditingSliderColor = true
                                sendHapticFeedback() // Trigger haptic feedback
                            } else if isEditingSliderColor {
                                sendColor() // Call only when user releases the slider
                                isEditingSliderColor = false
                            }
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
                .padding(.bottom, 20)
            }
//            .background(.gray.opacity(0.2))
//            .padding()
//            .shadow(radius: 5)
//            .shadow(color: .gray.opacity(0.5), radius: 5)
            
            
            
            // AI Button

        }
        .ignoresSafeArea()
        .padding()
        .cornerRadius(16)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Device Disconnected"), message: Text("Please reconnect your device."), dismissButton: .default(Text("OK")))
        }
        .onChange(of: pwmIntensityObj.isConnected) { _, newValue in
            if !newValue {
                showAlert = true
            }
        }
        .onAppear {
            withAnimation {
                wireHeight = isOn ? 500 : 300 // Animate height change
            }

            showAIButton = storeHistory.isQueueFull
        }
        .onReceive(storeHistory.objectWillChange) {
            showAIButton = storeHistory.isQueueFull
        }
        .opacity(isAIModeActive ? 0.5 : 1.0)
        .allowsHitTesting(!isAIModeActive)
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
        let byteArray : [UInt8] = [0x00, 0x00, 0x00, 0x00]
        sendMessage(hub: hub, message: byteArray)
        storeHistory.addElement(hub: hub, byteArray: byteArray)

    }
    
    private func sendOff() {
        let byteArray : [UInt8] = [0x00, 0x00, 0x00, 0x00]
        sendMessage(hub: hub, message: byteArray)
        storeHistory.addElement(hub: hub, byteArray: byteArray)

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
        storeHistory.addElement(hub: hub, byteArray: byteArray)
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
        storeHistory.addElement(hub: hub, byteArray: byteArray)
    }

    private func sendMessage(hub: Hub, message: [UInt8]) {
        if pwmIntensityObj.connectedDevices[hub.id] != nil {
            let data = Data(message)
            pwmIntensityObj.sendMessageToDevice(to: hub.id, message: [UInt8](data)) // Convert Data back to [UInt8]
            

        } else {
            print("Device not connected")
        }
    }
}




#Preview {
    PWM2LEDView(hub: Hub(name: "Test Hub"))
}
