//
//  MiniControllerView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

struct MiniControllerView: View {
    // Add this property to track active PWM LED ellipses
    @State private var activePWMLEDs: Set<Int> = []
    @AppStorage("lampPWM") private var isOn: Bool = false
    @State private var mode: String = "PWM"
    @State private var wireHeight: CGFloat = 500 // Initial height of the wire image
    let hub: Hub
    @Binding var brightness: Double
    @Binding var warmCold: Double

    @State private var selectedColor: Color = .emerald // Default color
    @State private var colorValue: Double = 0.0 // Represents position on rainbow slider

    @State private var selectedPWM: Int? = nil
    @State private var selectedRGB: Int? = nil
    @ObservedObject var miniPwmIntensityObj = BluetoothManager.shared  // Observing BluetoothManager

    let selectColorObj = BluetoothManager()
    
    // Array to store brightness values for each PWM LED
    @State private var pwmBrightness: [Double] = Array(repeating: 50.0, count: 5)
    
    // Animation states
    @State private var isAppearing = false

    var body: some View {
        ZStack {
            
            // Background gradient
            ElegantGradientBackgroundView()
                .ignoresSafeArea()
            
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
                        .fill(mode == "RGB" ? (selectedRGB != nil ? selectedColor : .white) : .white)
                        .frame(width: 180, height: 45)
                        .opacity(
                            mode == "RGB"
                            ? (selectedRGB != nil ? 0.8 : 0.3)  // RGB mode opacity
                            : (selectedPWM != nil ? (pwmBrightness[selectedPWM! - 1] / 100.0) : 0.3)  // PWM mode opacity
                        )
                        .blur(radius: 15)
                        .padding(.top, 160)
                        .animation(.easeInOut(duration: 0.3), value: mode)
                        .animation(.easeInOut(duration: 0.3), value: selectedRGB)
                        .animation(.easeInOut(duration: 0.3), value: selectedColor)
                        .animation(.easeInOut(duration: 0.3), value: selectedPWM)
                        .animation(.easeInOut(duration: 0.3), value: pwmBrightness)
                    
                    Image("ceilingHorizaontal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            }
                        }
                    
                    Ellipse()
                        .fill(mode == "RGB" ? (selectedRGB != nil ? selectedColor : .white) : .white)
                        .frame(width: 120, height: 45)
                        .opacity(
                            mode == "RGB"
                            ? (selectedRGB != nil ? 0.8 : 0.3)  // RGB mode opacity
                            : (selectedPWM != nil ? (pwmBrightness[selectedPWM! - 1] / 100.0) : 0.3)  // PWM mode opacity
                        )
                        .blur(radius: 12)
                        .padding(.top, 100)
                        .animation(.easeInOut(duration: 0.3), value: mode)
                        .animation(.easeInOut(duration: 0.3), value: selectedRGB)
                        .animation(.easeInOut(duration: 0.3), value: selectedColor)
                        .animation(.easeInOut(duration: 0.3), value: selectedPWM)
                        .animation(.easeInOut(duration: 0.3), value: pwmBrightness)


                }
                .padding(.top, -50)

            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 125) // Adjust this value to fine-tune the position
            VStack {
                HStack{
                    // Header with subtle animation
                    Text("Mini \nController")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.alabaster)
                        .padding(.top)
                        .scaleEffect(isAppearing ? 1.0 : 0.9)
                        .opacity(isAppearing ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isAppearing)
                    Spacer()
                }
                Spacer()
                Spacer()
                // Selected LED Controls
                if selectedPWM != nil || selectedRGB != nil {
                    GeometryReader { geometry in
                        VStack(alignment: .leading, spacing: 20) {
                            // PWM Controls
                            if mode == "PWM" && selectedPWM != nil {
                                if let pwm = selectedPWM {
                                    Spacer()

                                    HStack {
                                        Text("PWM LED \(pwm)")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.charlestonGreen)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(pwmBrightness[pwm - 1]))%")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.emerald)
                                    }
                                    
                                    // Brightness Slider
                                    HStack(spacing: 12) {
                                        Image(systemName: "sun.min.fill")
                                            .foregroundColor(.emerald.opacity(0.7))
                                        
                                        Slider(value: $pwmBrightness[pwm - 1], in: 0...100, step: 1, onEditingChanged: { isEditing in
                                            if isEditing {
                                                sendHapticFeedback()
                                            } else {
                                                sendHapticFeedback()
                                                sendIntensity(pwmled: pwm, brightness: pwmBrightness[pwm - 1])
                                            }
                                        })
                                        .onChange(of: pwmBrightness[pwm - 1]) { _, newValue in
                                            // Animate opacity change when brightness changes
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                // Update happens automatically through binding
                                            }
                                        }
                                        .accentColor(.emerald)
                                        
                                        Image(systemName: "sun.max.fill")
                                            .foregroundColor(.emerald)
                                    }
                                }
                            }
                            
                            // RGB Controls
                            if mode == "RGB" && selectedRGB != nil {
                                if let lednumber = selectedRGB {
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("RGB LED \(lednumber)")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundColor(.charlestonGreen)
                                            
                                            Spacer()
                                            
                                            Circle()
                                                .fill(selectedColor)
                                                .frame(width: 24, height: 24)
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        }
                                        
                                        // Rainbow Color Picker
                                        VStack(spacing: 8) {
                                            RainbowSlider(value: $colorValue, selectedColor: $selectedColor)
                                                .frame(height: 24)
                                                .cornerRadius(12)
                                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 2))
                                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                                .onChange(of: colorValue) { oldValue, newValue in
                                                    selectedColor = getColorFromSlider(newValue)
                                                    sendHapticFeedback()
                                                }
                                                .simultaneousGesture(DragGesture().onEnded { _ in
                                                    sendColorToLED(selectedColor, ledNumber: lednumber)
                                                })
                                            
                                            // Color presets
                                            HStack(spacing: 12) {
                                                ForEach([Color.red, Color.green, Color.blue, Color.yellow, Color.purple], id: \.self) { color in
                                                    Circle()
                                                        .fill(color)
                                                        .frame(width: 30, height: 30)
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                                        .onTapGesture {
                                                            selectedColor = color
                                                            sendColorToLED(color, ledNumber: lednumber)
                                                            sendHapticFeedback()
                                                        }
                                                }
                                            }
                                            .padding(.top, 8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .offset(y: selectedPWM != nil || selectedRGB != nil ? 0 : geometry.size.height)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedPWM)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedRGB)
                    }
                    .transition(.move(edge: .bottom))
                }
                HStack{
                    Button(action: {
                        mode = (mode == "PWM") ? "RGB" : "PWM"
                    }) {
                        Text(mode)
                            .padding()
                            .bold()
                            .frame(width: 80, height: 50)
                            .background(mode == "PWM" ? Color.alabaster : Color.etonBlue)
                            .foregroundColor(.charlestonGreen)
                            .cornerRadius(10)
                            .animation(.easeInOut, value: mode)
                            .shadow(radius: 5)
                    }
      
                    // Conditional content based on mode
                    if mode == "PWM" {
                        // PWM LED Buttons
                        VStack(alignment: .leading, spacing: 5) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 5) {
                                    ForEach(1...5, id: \.self) { index in
                                        
                                        MiniButton(
                                            title: "LED \(index)",
                                            isSelected: selectedPWM == index,
                                            color: .emerald,
                                            action: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedPWM = (selectedPWM == index) ? nil : index
                                                }
                                            }
                                        )
                                        .transition(.scale)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 6)
                        .transition(.opacity)
                    } else {
                        // RGB LED Buttons
                        VStack(alignment: .leading, spacing: 16) {

                            
                            HStack(spacing: 16) {
                                ForEach(1...2, id: \.self) { index in
                                    MiniButton(
                                        title: "RGB \(index)",
                                        isSelected: selectedRGB == index,
                                        color: .etonBlue,
                                        selectedColor: selectedRGB == index ? selectedColor : nil,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedRGB = (selectedRGB == index) ? nil : index
                                            }
                                        }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                    }
                }
            }
            .padding()

        }
        .onAppear {
            // Trigger animations when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isAppearing = true
                }
            }
        }
    }

    // Function to send color to LED
    func sendColorToLED(_ color: Color, ledNumber: Int) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redByte = UInt8(red * 255)
        let greenByte = UInt8(green * 255)
        let blueByte = UInt8(blue * 255)

        var byteArray: [UInt8] = [0x03, 0x00, 0x00, 0x00]

        if let po = UInt8(exactly: ledNumber + 5) {
            byteArray[1] = po
            byteArray[2] = redByte
            byteArray[3] = greenByte
            byteArray.append(blueByte)

            sendMessage(hub: hub, message: byteArray)

            print("Sending LED number:", ledNumber, "Color:", byteArray)
        } else {
            print("Error: LED number out of range!")
        }
    }

    // Function to map slider value to a color
    func getColorFromSlider(_ value: Double) -> Color {
        let hue = value / 100.0
        return Color(hue: hue, saturation: 1, brightness: 1)
    }

    private func sendIntensity(pwmled: Int, brightness: Double) {
        let brightnessValue = Int(brightness)
        let ledNumber = Int(pwmled)

        // Construct the byte array
        let byteArray: [UInt8] = [
            0x03,  // Assuming a different identifier for intensity (change if needed)
            UInt8(ledNumber & 0xFF),
            UInt8(brightnessValue & 0xFF)
        ]

        // Convert byte values into a hex string format "0x01, 0x2E, 0x4A"
        let hexString = byteArray.map { String(format: "0x%02X", $0) }.joined(separator: ", ")
        print("Sending intensity to LED \(ledNumber): \(hexString))")
        // Send the formatted hex string
        sendMessage(hub: hub, message: byteArray)
    }
    
    private func sendMessage(hub: Hub, message: [UInt8]) {
        if miniPwmIntensityObj.connectedDevices[hub.id] != nil {
            
            let data = Data(message)
            miniPwmIntensityObj.sendMessageToDevice(to: hub.id, message: [UInt8](data)) // Convert Data back to [UInt8]

        } else {
            print("Device not connected")
        }
    }
    
    func sendHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct MiniButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    var selectedColor: Color? = nil // Add this property
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .foregroundColor(isSelected ? .white : .charlestonGreen)
            }
            .frame(minWidth: 25, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? (selectedColor ?? color) : Color.alabaster)
                    .shadow(color: isSelected ? (selectedColor ?? color).opacity(0.4) : Color.black.opacity(0.05),
                            radius: isSelected ? 6 : 4,
                            x: 0,
                            y: isSelected ? 3 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? (selectedColor ?? color) : Color.gray.opacity(0.2), lineWidth: 1.5)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

struct MiniControllerPreviewWrapper: View {
    @State private var brightness: Double = 0.5
    @State private var warmCold: Double = 0.5

    var body: some View {
        // Provide a dummy Hub instance for preview purposes
        let dummyHub = Hub(name: "Dummy Hub")
        MiniControllerView(hub: dummyHub, brightness: $brightness, warmCold: $warmCold)
    }
}

#Preview {
    MiniControllerPreviewWrapper()
}
