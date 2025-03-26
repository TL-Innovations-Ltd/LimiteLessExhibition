//
//  DataRGBView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

import SwiftUI

struct DataRGBView: View {
    @AppStorage("lampRGB") private var isOn: Bool = false
    @State private var selectedColor: Color = .emerald
    @State private var showingColorPicker = false
    @State private var selectedMode: ColorMode = .solid
    @State private var colorValue: Double = 0.0 // Represents position on rainbow slider
    @State private var redValue: Int = 0
    @State private var greenValue: Int = 0
    @State private var blueValue: Int = 0

    @ObservedObject var sharedDevice = SharedDevice.shared
    
    @State private var wireHeight: CGFloat = 300 // Initial height of the wire image
    @State private var led2Brightness: Double = 50

    @State private var showPopup = false
    @State private var navigateToHome = false
    let selectColorObj = BluetoothManager.shared
    let hub: Hub

    @State private var showAlert = false

    enum ColorMode: String, CaseIterable, Identifiable {
        case solid = "Solid"
        case rainbow = "Rainbow"

        var id: String { self.rawValue }
    }

    var body: some View {
        ZStack{
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
                        .fill(selectedColor)
                        .frame(width: 180, height: 45)
                        .opacity(isOn ? 0.1 : 0.0) // Adjust opacity based on brightness
                        .blur(radius: 10)
                        .padding(.top, 160)
                    Image("ceilingHorizaontal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            }
                        }
                        .shadow(color:.white, radius: 6)
                    Ellipse()
                        .fill(selectedColor)
                        .frame(width: 120, height: 45)
                        .opacity(isOn ? 0.4 : 0.0) // Adjust opacity based on brightness
                        .blur(radius: 10)
                        .padding(.top, 100)

  
                    
                }
                .padding(.top, -50)

            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 125) // Adjust this value to
            
            VStack{
                HStack {
                    Text("RGB Led")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.alabaster)
                        .padding(.top)
                        .shadow(color:.white, radius: 6)
                    Spacer()

                    Toggle(isOn: $isOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .onChange(of: isOn) { oldValue, newValue in
                        withAnimation {
                            wireHeight = newValue ? 500 : 300 // Animate height change
                        }
                        sendLampState()
                    }
                    .onAppear {
                        withAnimation {
                            wireHeight = isOn ? 500 : 300 // Animate height change
                        }
                        sendLampState()
                    }
                }
                Spacer()

                // Rainbow Color Picker
                RainbowSlider(value: $colorValue, selectedColor: $selectedColor)
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

                HStack {
                    VStack {
                        HStack {
                            Text("Red")
                                .foregroundColor(.charlestonGreen)
                                .bold(true)
                            TextField("0", value: $redValue, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 50)
                                .onChange(of: redValue) { oldValue, newValue in
                                    checkAndSendColor()
                                }
                        }
                    }
                    VStack {
                        HStack {
                            Text("Green")
                                .foregroundColor(.charlestonGreen)
                                .bold(true)
                            TextField("0", value: $greenValue, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 50)
                                .onChange(of: redValue) { oldValue, newValue in
                                    checkAndSendColor()
                                }
                        }
                    }
                    VStack {
                        HStack {
                            Text("Blue")
                                .foregroundColor(.charlestonGreen)
                                .bold(true)
                            TextField("0", value: $blueValue, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 50)
                                .onChange(of: redValue) { oldValue, newValue in
                                    checkAndSendColor()
                                }
                        }
                    } // rgb(214,23,210)
                }
                .padding(.top)

            }
            .padding()

            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $selectedColor)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Device Disconnected"), message: Text("Please reconnect your device."), dismissButton: .default(Text("OK")))
            }
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
        .background(
            LinearGradient(
                            gradient: Gradient(colors: [
                                Color.charlestonGreen, // Eton

                                Color.alabaster  // Alabaster
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                            )
        )

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

    func sendColorToLED(red: Int, green: Int, blue: Int) {
        let redByte = UInt8(red)
        let greenByte = UInt8(green)
        let blueByte = UInt8(blue)

        // Create byte array with correct length and protocol format
        let byteArray: [UInt8] = [0x02, redByte, greenByte, blueByte]

        sendMessage(hub: hub, message: byteArray)
    }

    private func checkAndSendColor() {
        if redValue > 0 && greenValue > 0 && blueValue > 0 {
            sendColorToLED(red: redValue, green: greenValue, blue: blueValue)
        }
    }

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
