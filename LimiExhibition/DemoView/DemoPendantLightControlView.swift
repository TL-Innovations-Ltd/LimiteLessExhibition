//
//  DemoPendantLightControlView.swift
//  Limi
//
//  Created by Mac Mini on 07/04/2025.
//


import SwiftUI

struct DemoPendantLightControlView: View {
    @State var device: DemoDevice
    @Binding var isPresented: Bool
    


    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.5, blue: 0.4),
                    Color(red: 0.3, green: 0.25, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 0) {

                
                HStack {
                    Text(device.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $device.isOn)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Pendant lamp image
                ZStack {
                    // Lamp cord
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 1)
                        .frame(height: 150)
                    
                    // Lamp shade positioned at bottom of cord
                    VStack {
                        Spacer()
                        ZStack {
                            // Lamp shade
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 60, height: 40)
                            
                            // Light glow
                            Circle()
                                .fill(Color.yellow.opacity(device.isOn ? 0.5 : 0))
                                .frame(width: 80, height: 80)
                                .blur(radius: 20)
                                .offset(y: 10)
                        }
                    }
                    .frame(height: 150)
                }
                .frame(height: 200)
                
                // Brightness control
                HStack {
                    Text("\(Int(device.brightness))%")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Custom vertical slider
                    ZStack(alignment: .bottom) {
                        // Track
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 150)
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 20, height: 150 * CGFloat(device.brightness / 100))
                        
                        // Thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                            .offset(y: -150 * CGFloat(device.brightness / 100) + 15)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let height: CGFloat = 150
                                let percentage = 1 - min(max(0, value.location.y / height), 1)
                                device.brightness = Double(percentage) * 100
                            }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Color temperature arc slider
                VStack {
                    ZStack {
//                        CurvedSlider(
//                            value: $warmCold,
//                            in: 0...100,
//                            step: 1,
//                            onEditingChanged: { isEditing in
//                                if isEditing {
//                                    isEditingSliderColor = true
//                                    sendHapticFeedback()
//                                } else if isEditingSliderColor {
//                                    isEditingSliderColor = false
//                                }
//                            },
//                            disabled: !isOn
//                        )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    
                    // Labels
                    HStack {
                        Text("Warm")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Cool")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(.horizontal, 50)
                }
                .padding(.bottom, 50)
            }
            .padding()
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
    }
    func sendHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.height)
        let radius = rect.width / 2
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}

