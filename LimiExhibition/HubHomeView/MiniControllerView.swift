//
//  MiniControllerView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//


import SwiftUI

import SwiftUI

struct MiniControllerView: View {
    @Binding var brightness: Double
    @Binding var warmCold: Double
    
    @State private var selectedColor: Color = .emerald

    @State private var selectedPWM: Int? = nil
    @State private var selectedRGB: Int? = nil
    @ObservedObject var miniPwmIntensityObj = BluetoothManager()  // Observing BluetoothManager

    let selectColorObj = BluetoothManager()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Mini Controller")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
                .padding(.top)
            
            // PWM LED Buttons
            VStack(alignment: .leading, spacing: 16) {
                Text("PWM LEDs")
                    .font(.headline)
                    .foregroundColor(.charlestonGreen)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        MiniButton(
                            title: "LED\n \(index)",
                            isSelected: selectedPWM == index,
                            color: .emerald,
                            action: {
                                selectedPWM = (selectedPWM == index) ? nil : index
                            }
                        )
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // RGB Buttons
            VStack(alignment: .leading, spacing: 16) {
                Text("RGB LEDs")
                    .font(.headline)
                    .foregroundColor(.charlestonGreen)
                
                HStack(spacing: 12) {
                    ForEach(1...2, id: \.self) { index in
                        MiniButton(
                            title: "RGB \(index)",
                            isSelected: selectedRGB == index,
                            color: .etonBlue,
                            action: {
                                selectedRGB = (selectedRGB == index) ? nil : index
                            }
                        )
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Selected LED Controls
            if selectedPWM != nil || selectedRGB != nil {
                VStack(alignment: .leading, spacing: 16) {
                    if let pwm = selectedPWM {
                        Text("PWM LED \(pwm) Controls")
                            .font(.headline)
                            .foregroundColor(.charlestonGreen)
                        
                        // Brightness Slider
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.emerald)
                            
                            Slider(value: $brightness, in: 0...100, step: 1, onEditingChanged: { _ in
                                sendIntensity(pwmled: pwm)
                                            })
                        }
                    }
                    
                    if let lednumber = selectedRGB {
                        Text("RGB LED \(lednumber) Controls")
                            .font(.headline)
                            .foregroundColor(.charlestonGreen)
                        
                        // Color Buttons
                        HStack(spacing: 12) {
                            ColorPresetButton(color: .red, selectedColor: $selectedColor) {
                                var byteArray: [UInt8] = [0x03, 0xFF, 0x00, 0x00] // ✅ Use `var` to modify

                                if let po = UInt8(exactly: lednumber+5) {
                                    byteArray.insert(po, at: 1)  // ✅ Insert `po` at index 1

                                    selectColorObj.sendMessage(byteArray)
                                    print("Sending LED number:", lednumber)
                                } else {
                                    print("Error: LED number out of range!")
                                }
                            }
                            ColorPresetButton(color: .green, selectedColor: $selectedColor){
                                //008000
                                var byteArray: [UInt8] = [0x03, 0x00, 0x80, 0x00] // ✅ Use `var` to modify

                                if let po = UInt8(exactly: lednumber+5) {
                                    byteArray.insert(po, at: 1)  // ✅ Insert `po` at index 1

                                    selectColorObj.sendMessage(byteArray)
                                    print("Sending LED number:", lednumber)
                                } else {
                                    print("Error: LED number out of range!")
                                }
                            }
                            
                            ColorPresetButton(color: .blue, selectedColor: $selectedColor){
                                //0000FF
                                var byteArray: [UInt8] = [0x03, 0x00, 0x00, 0xFF] // ✅ Use `var` to modify

                                if let po = UInt8(exactly: lednumber+5) {
                                    byteArray.insert(po, at: 1)  // ✅ Insert `po` at index 1

                                    selectColorObj.sendMessage(byteArray)
                                    print("Sending LED number:", lednumber)
                                } else {
                                    print("Error: LED number out of range!")
                                }
                            }
                            ColorPresetButton(color: .purple, selectedColor: $selectedColor){
                                //800080
                                var byteArray: [UInt8] = [0x03, 0x80, 0x00, 0x80] // ✅ Use `var` to modify

                                if let po = UInt8(exactly: lednumber+5) {
                                    byteArray.insert(po, at: 1)  // ✅ Insert `po` at index 1

                                    selectColorObj.sendMessage(byteArray)
                                    print("Sending LED number:", lednumber)
                                } else {
                                    print("Error: LED number out of range!")
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.spring(), value: selectedPWM)
                .animation(.spring(), value: selectedRGB)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
    }
    private func sendIntensity(pwmled: Int) {
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

        // Send the formatted hex string
        miniPwmIntensityObj.sendMessage(byteArray)
    }

}


struct MiniButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .charlestonGreen)
                .background(isSelected ? color : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
    }
}

struct MiniControllerPreviewWrapper: View {
    @State private var brightness: Double = 0.5
    @State private var warmCold: Double = 0.5

    var body: some View {
        MiniControllerView(brightness: $brightness, warmCold: $warmCold)
    }
}

#Preview {
    MiniControllerPreviewWrapper()
}

