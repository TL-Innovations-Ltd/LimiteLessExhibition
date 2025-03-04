//
//  PWM2LEDView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//


import SwiftUI

struct PWM2LEDView: View {
    @State private var led1Brightness: Double = 75
    @State private var led2Brightness: Double = 50
    
    var body: some View {
        VStack(spacing: 24) {
            Text("PWM 2 LED Controller")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
                .padding(.top)
            
            // LED 1 Control
            LEDControlView(
                title: "LED 1",
                brightness: $led1Brightness,
                color: .emerald
            )
            
            // LED 2 Control
            LEDControlView(
                title: "LED 2",
                brightness: $led2Brightness,
                color: .etonBlue
            )
            
            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
    }
}

struct LEDControlView: View {
    let title: String
    @Binding var brightness: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.charlestonGreen)
                
                Spacer()
                
                Text("\(Int(brightness))%")
                    .font(.subheadline)
                    .foregroundColor(.charlestonGreen.opacity(0.7))
            }
            
            HStack(spacing: 16) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(color.opacity(brightness/100))
                    .font(.title2)
                
                Slider(value: $brightness, in: 0...100, step: 1)
                    .accentColor(color)
            }
            
            // LED Visualization
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(brightness/100))
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: color.opacity(brightness/200), radius: 8, x: 0, y: 0)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    PWM2LEDView()
}
