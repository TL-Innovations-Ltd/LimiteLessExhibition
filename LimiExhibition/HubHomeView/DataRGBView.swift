//
//  DataRGBView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

struct DataRGBView: View {
    @State private var selectedColor: Color = .emerald
    @State private var showingColorPicker = false
    @State private var selectedMode: ColorMode = .solid
    // Bluetooth Color Message send
    let selectColorObj = BluetoothManager()
    @State private var isOn = false

    
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
                .onChange(of: isOn) { newValue in
                                        sendLampState()
                                    }
            }

            
            // Mode Selection
            Picker("Mode", selection: $selectedMode) {
                ForEach(ColorMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedMode == .solid {
                // Color Display
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedColor)
                    .frame(height: 120)
                    .padding(.horizontal)
                    .shadow(color: selectedColor.opacity(0.3), radius: 10, x: 0, y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    
                // Color Presets
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                    ColorPresetButton(color: .red, selectedColor: $selectedColor){
                        let byteArray: [UInt8] = [0x02, 0xFF, 0x00, 0x00]
                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .orange, selectedColor: $selectedColor){
                        let byteArray: [UInt8] = [0x02, 0xFF, 0x8A, 0x22]
                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .yellow, selectedColor: $selectedColor){
                        let byteArray: [UInt8] = [0x02, 0xFF, 0xFF, 0x00]
                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .green, selectedColor: $selectedColor){
                        let byteArray: [UInt8] = [0x02, 0x00, 0x80, 0x00]
                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .blue, selectedColor: $selectedColor){
                        let byteArray: [UInt8] = [0x02, 0x00, 0x00, 0xFF]
                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .purple, selectedColor: $selectedColor){
                        let byteArray: [UInt8] = [0x02, 0x80, 0x00, 0x80]
                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .pink, selectedColor: $selectedColor){
                        //FFC0CB
                        let byteArray: [UInt8] = [0x02, 0xFF, 0xC0, 0xCB]

                        selectColorObj.sendMessage(byteArray)
                    }

                    ColorPresetButton(color: .white, selectedColor: $selectedColor){
                        //FFFFFF
                        let byteArray: [UInt8] = [0x02, 0xFF, 0xFF, 0xFF]

                        selectColorObj.sendMessage(byteArray)
                    }

                }
                .padding()
                .opacity(isOn ? 1.0 : 0.5) // Dim when OFF
                    .disabled(!isOn)
            } else {
//                // Rainbow Mode
//                RainbowView()
//                    .frame(height: 120)
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
//
//                // Rainbow Speed Control
//                VStack(alignment: .leading) {
//                    Text("Rainbow Speed")
//                        .font(.headline)
//                        .foregroundColor(.charlestonGreen)
//
//                    HStack {
//                        Image(systemName: "tortoise")
//                            .foregroundColor(.gray)
//
//                        Slider(value: .constant(0.5), in: 0...1)
//                            .accentColor(.emerald)
//
//                        Image(systemName: "hare")
//                            .foregroundColor(.gray)
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(16)
//                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//                .padding(.horizontal)
            }
            
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
        .onChange(of: selectColorObj.isConnected) { newValue in
            if !newValue {
                showAlert = true
            }
        }
    }

    
    // Function to send lamp state
    private func sendLampState() {
        if isOn {
            let byteArray: [UInt8] = [0x02, 0xFF, 0xFF, 0x00]
            selectColorObj.sendMessage(byteArray)
        } else {
            let byteArray: [UInt8] = [0x02, 0x00, 0x00, 0x00]
            selectColorObj.sendMessage(byteArray)
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
    DataRGBView()
}
