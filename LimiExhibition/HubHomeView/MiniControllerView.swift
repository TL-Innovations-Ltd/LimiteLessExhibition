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
    
    @State private var selectedColor: Color = .emerald// Default color
    @State private var colorValue: Double = 0.0 // Represents position on rainbow slider

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

            // RGB LED Buttons
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

                            Slider(value: $brightness, in: 0...100, step: 1)
                                .onChange(of: brightness) {
                                    sendIntensity(pwmled: pwm)
                                }
                        }
                    }

                    // RGB LED Color Picker
                    if let lednumber = selectedRGB {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RGB LED \(lednumber) Controls")
                                .font(.headline)
                                .foregroundColor(.charlestonGreen)

                            // Rainbow Color Picker
                            RainbowSlider(value: $colorValue)
                                .frame(height: 20)
                                .onChange(of: colorValue) { oldValue, newValue in
                                    let color = getColorFromSlider(newValue)
                                    selectedColor = color
                                    sendColorToLED(color, ledNumber: lednumber)
                                }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }

            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
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

            selectColorObj.writeDataToFF03(byteArray)
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
        print("Sending intensity to LED \(ledNumber): \(hexString))")
        // Send the formatted hex string
        miniPwmIntensityObj.writeDataToFF03(byteArray)
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

