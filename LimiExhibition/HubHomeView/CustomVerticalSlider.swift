//
//  CustomVerticalSlider.swift
//  Limi
//
//  Created by Mac Mini on 29/03/2025.
//

import SwiftUI

struct CustomVerticalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var onEditingChanged: (Bool) -> Void
    var isDisabled: Bool

    private let trackWidth: CGFloat = 10
    private let knobSize: CGFloat = 30
    private let trackHeight: CGFloat = 200

    @State private var isDragging = false

    var body: some View {
        VStack {
            // Custom Track
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: trackWidth, height: trackHeight)
                .cornerRadius(trackWidth / 2)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
                        .frame(width: trackWidth, height: trackHeight * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)))
                        .cornerRadius(trackWidth / 2)
                )
                .padding(.vertical, 20)

            // Knob
            Circle()
                .fill(Color.white)
                .frame(width: knobSize, height: knobSize)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .offset(y: -CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackHeight)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            guard !isDisabled else { return }
                            let location = gesture.location.y
                            let percentage = 1 - min(max(0, location / trackHeight), 1) // Invert for vertical slider
                            let newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)

                            // Apply stepping if needed
                            if step > 0 {
                                value = round(newValue / step) * step
                            } else {
                                value = newValue
                            }

                            onEditingChanged(true)
                        }
                        .onEnded { _ in
                            onEditingChanged(false)
                        }
                )
        }
        .frame(height: trackHeight + knobSize) // Adjust the frame to fit the track and knob
        .disabled(isDisabled)
    }
}

