//
//  DataRGBView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

struct DataRGBView: View {
    @AppStorage("lampRGB") private var isOn: Bool = false
    @State private var selectedColor: Color = .emerald
    @State private var showingColorPicker = false
    @State private var selectedMode: ColorMode = .solid
    @State private var colorValue: Double = 0.0 // Represents position on rainbow slider

    
    @ObservedObject var sharedDevice = SharedDevice.shared
    
    @State private var showPopup = false
    @State private var navigateToHome = false
    // Bluetooth Color Message send
    let selectColorObj = BluetoothManager.shared
    let hub: Hub

    @State private var showAlert = false
    
    enum ColorMode: String, CaseIterable, Identifiable {
        case solid = "Solid"
        case rainbow = "Rainbow"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack{
                Text("1 Data RGB Controller")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.charlestonGreen)
                    .padding(.top)
                Spacer()
                
                Toggle(isOn: $isOn) {}
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .onChange(of: isOn) {oldValue, newValue in

                                        sendLampState()
                                    }
                .onAppear{
                    sendLampState()
                }
            }

            // Rainbow Color Picker
            RainbowSlider(value: $colorValue)
                .frame(height: 20)
                .onChange(of: colorValue) { oldValue, newValue in
                    selectedColor = getColorFromSlider(newValue)
                    
                    // Haptic feedback on value change
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
                .simultaneousGesture(DragGesture().onEnded { _ in
                    // Send color only when user releases the slider
                    sendColorToLED(selectedColor)
                })
            
            // Mode Selection
//            Picker("Mode", selection: $selectedMode) {
//                ForEach(ColorMode.allCases) { mode in
//                    Text(mode.rawValue).tag(mode)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal)
//            
//            if selectedMode == .solid {
//                // Color Display
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(selectedColor)
//                    .frame(height: 120)
//                    .padding(.horizontal)
//                    .shadow(color: selectedColor.opacity(0.3), radius: 10, x: 0, y: 0)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.white, lineWidth: 2)
//                    )
//                    
//                // Color Presets
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
//                    ColorPresetButton(color: .red, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0xFF, 0x00, 0x00] // Red
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .green, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0x00, 0xFF, 0x00] // Green
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .blue, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0x00, 0x00, 0xFF] // Blue
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .yellow, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0xFF, 0xFF, 0x00] // Yellow
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .purple, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0x80, 0x00, 0x80] // Purple
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .orange, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0xFF, 0xA5, 0x00] // Orange
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .cyan, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0x00, 0xFF, 0xFF] // Cyan
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: Color(red: 1.0, green: 0.0, blue: 1.0), selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0xFF, 0x00, 0xFF] // Magenta
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .brown, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0xA5, 0x2A, 0x2A] // Brown
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .gray, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0x80, 0x80, 0x80] // Gray
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .white, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0xFF, 0xFF, 0xFF] // White
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//                    ColorPresetButton(color: .black, selectedColor: $selectedColor) {
//                        let byteArray: [UInt8] = [0x02, 0x00, 0x00, 0x00] // Black
//                        sendMessage(hub: hub, message: byteArray)
//                    }
//
//
//                }
//                .padding()
//                .opacity(isOn ? 1.0 : 0.5) // Dim when OFF
//                .disabled(!isOn)
//            } else {
////                // Rainbow Mode
////                RainbowView()
////                    .frame(height: 120)
////                    .cornerRadius(16)
////                    .padding(.horizontal)
////                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
////
////                // Rainbow Speed Control
////                VStack(alignment: .leading) {
////                    Text("Rainbow Speed")
////                        .font(.headline)
////                        .foregroundColor(.charlestonGreen)
////
////                    HStack {
////                        Image(systemName: "tortoise")
////                            .foregroundColor(.gray)
////
////                        Slider(value: .constant(0.5), in: 0...1)
////                            .accentColor(.emerald)
////
////                        Image(systemName: "hare")
////                            .foregroundColor(.gray)
////                    }
////                }
////                .padding()
////                .background(Color.white)
////                .cornerRadius(16)
////                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
////                .padding(.horizontal)
//            }
            
            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerView(selectedColor: $selectedColor)
        }
        // 🔹 Show alert when the device disconnects
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Device Disconnected"), message: Text("Please reconnect your device."), dismissButton: .default(Text("OK")))
        }

        // 🔹 Observe changes in isConnected
        .onChange(of: selectColorObj.isConnected) { oldValue, newValue in

            if !newValue {
                showAlert = true
            }
        }
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
    
    // Function to map slider value to a color
    func getColorFromSlider(_ value: Double) -> Color {
        let hue = value / 100.0
        return Color(hue: hue, saturation: 1, brightness: 1)
    }
    
    func sendColorToLED(_ color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redByte = UInt8(red * 255)
        let greenByte = UInt8(green * 255)
        let blueByte = UInt8(blue * 255)

        // Create byte array with correct length and protocol format
        let byteArray: [UInt8] = [0x02, redByte, greenByte, blueByte]

        sendMessage(hub: hub, message: byteArray)
    }
    
    // Function to send lamp state
    private func sendLampState() {
        if isOn {
            let byteArray: [UInt8] = [0x02, 0xFF, 0xFF, 0x00]
            sendMessage(hub: hub, message: byteArray)
            
        } else {
            let byteArray: [UInt8] = [0x02, 0x00, 0x00, 0x00]
            sendMessage(hub: hub, message: byteArray)
            
        }
    }
    
    private func sendMessage(hub: Hub, message: [UInt8]) {
        if selectColorObj.connectedDevices[hub.id] != nil {
            let data = Data(message)
            selectColorObj.sendMessageToDevice(to: hub.id, message: [UInt8](data)) // Convert Data back to [UInt8]

        } else {
            print("Device not connected")
        }
    }
}

struct ColorPresetButton: View {
    let color: Color
    @Binding var selectedColor: Color
    var action: () -> Void  // Explicitly require an action closure

    
    var body: some View {
        Button(action: {
            selectedColor = color
        }) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
                .overlay(
                    Circle()
                        .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                )
                .onTapGesture {
                    selectedColor = color
                    action()  // Call the action when the button is tapped
                }
        }
    }
}

struct RainbowView: View {
    @State private var animationOffset: CGFloat = 0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red]
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: -animationOffset * geometry.size.width)
            .frame(width: geometry.size.width * 2)
            .onAppear {
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                    animationOffset = 1
                }
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Select Color", selection: $selectedColor)
                    .padding()
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedColor)
                    .frame(height: 100)
                    .padding()
                    .shadow(color: selectedColor.opacity(0.3), radius: 10, x: 0, y: 0)
                
                Spacer()
            }
            .navigationTitle("Color Picker")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
#Preview {
    DataRGBView(hub: Hub(name: "Test Hub"))
}
