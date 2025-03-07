//
//  MiniControllerView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//


import SwiftUI

struct MiniControllerView: View {
    @State private var selectedPWM: Int? = nil
    @State private var selectedRGB: Int? = nil
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
                            title: "LED \(index)",
                            isSelected: selectedPWM == index,
                            color: .emerald,
                            action: {
                                if selectedPWM == index {
                                    selectedPWM = nil
                                } else {
                                    selectedPWM = index
                                }
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
                                if selectedRGB == index {
                                    selectedRGB = nil
                                } else {
                                    selectedRGB = index
                                }
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
                        
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.emerald)
                            
                            Slider(value: .constant(0.7), in: 0...1)
                                .accentColor(.emerald)
                        }
                    }
                    
                    if let rgb = selectedRGB {
                        Text("RGB LED \(rgb) Controls")
                            .font(.headline)
                            .foregroundColor(.charlestonGreen)
                        
                        HStack(spacing: 12) {
                            ColorPresetButton(color: .red, selectedColor: .constant(.red)){
                                selectColorObj.sendMessage("orange")
                            }
                            ColorPresetButton(color: .green, selectedColor: .constant(.red)){
                                selectColorObj.sendMessage("orange")
                            }
                            ColorPresetButton(color: .blue, selectedColor: .constant(.red)){
                                selectColorObj.sendMessage("orange")
                            }
                            ColorPresetButton(color: .purple, selectedColor: .constant(.red)){
                                selectColorObj.sendMessage("orange")
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

#Preview {
    MiniControllerView()
}
