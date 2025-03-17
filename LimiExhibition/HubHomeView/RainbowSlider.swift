//
//  RainbowSlider.swift
//  Limi
//
//  Created by Mac Mini on 17/03/2025.
//

import SwiftUI

struct RainbowSlider: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Rainbow Gradient Bar
                LinearGradient(
                    gradient: Gradient(colors: [
                        .red, .orange, .yellow, .green, .blue, .purple
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2) // Subtle border effect
                )
                .frame(height: 40) // Increased height for better visibility

                // Selection Indicator
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.7), lineWidth: 2) // Glow effect
                    )
                    .offset(x: CGFloat(value / 100) * (geometry.size.width - 30))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = min(max(gesture.location.x / geometry.size.width * 100, 0), 100)
                                value = newValue
                            }
                    )
            }
        }
        .frame(height: 40)
        .padding(.horizontal)
    }
}
