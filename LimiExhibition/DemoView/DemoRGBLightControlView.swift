//
//  DemoRGBLightControlView.swift
//  Limi
//
//  Created by Mac Mini on 07/04/2025.
//


import SwiftUI

struct DemoRGBLightControlView: View {
    @State var device: DemoDevice
    @Binding var isPresented: Bool
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink]
    @State private var selectedColorMode: ColorMode = .solid
    
    enum ColorMode {
        case solid
        case rainbow
    }
    
    var body: some View {
        ZStack {
            // Background with blur effect based on current color
            LinearGradient(
                gradient: Gradient(colors: [
                    device.color.opacity(0.7),
                    device.color.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 30)
            .edgesIgnoringSafeArea(.all)
            
            // Semi-transparent overlay
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 0) {
                // Header
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
                
                // Lamp image
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
                                .fill(device.isOn ? device.color.opacity(0.7) : Color.clear)
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
                
                // Color controls
                VStack(spacing: 15) {
                    // Color mode buttons
                    HStack {
                        Button(action: {
                            selectedColorMode = .solid
                            device.isRainbowMode = false
                        }) {
                            Text("Select Color")
                                .fontWeight(.medium)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Paste color functionality would go here
                        }) {
                            Text("Paste Colour")
                                .fontWeight(.medium)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Color mode selection
                    HStack(spacing: 10) {
                        Button(action: {
                            selectedColorMode = .solid
                            device.isRainbowMode = false
                        }) {
                            Text("Solid Color")
                                .fontWeight(.medium)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedColorMode == .solid ? Color.green : Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            selectedColorMode = .rainbow
                            device.isRainbowMode = true
                        }) {
                            Text("Rainbow Color")
                                .fontWeight(.medium)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedColorMode == .rainbow ? Color.green : Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Color selection
                    HStack(spacing: 10) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(device.color == color ? Color.white : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    device.color = color
                                    selectedColorMode = .solid
                                    device.isRainbowMode = false
                                }
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .padding(.bottom, 30)
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
        .onAppear {
            // Start rainbow animation if in rainbow mode
            if device.isRainbowMode {
                startRainbowAnimation()
            }
        }
    }
    
    private func startRainbowAnimation() {
        guard device.isRainbowMode else { return }
        
        let baseTime: TimeInterval = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + baseTime) {
            let currentIndex = self.colors.firstIndex(where: { $0.description == self.device.color.description }) ?? 0
            let nextIndex = (currentIndex + 1) % self.colors.count
            
            withAnimation(.easeInOut(duration: baseTime)) {
                self.device.color = self.colors[nextIndex]
            }
            
            if self.device.isRainbowMode {
                self.startRainbowAnimation()
            }
        }
    }
}

