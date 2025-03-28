//
//  SmartLightControl.swift
//  Limi
//
//  Created by Mac Mini on 28/03/2025.
//


import SwiftUI

struct SmartLightControl: View {
    @State private var brightness: Double = 64
    @State private var selectedDevice: String = "Device 1"
    @State private var selectedColor: String = "yellow"
    
    // Different color options for the color bar
    let colorOptions: [(name: String, color: Color)] = [
        ("white", Color.white),
        ("teal", Color(red: 79/255, green: 209/255, blue: 197/255)),
        ("yellow", Color(red: 246/255, green: 224/255, blue: 94/255)),
        ("pink", Color(red: 246/255, green: 135/255, blue: 179/255)),
        ("purple", Color(red: 159/255, green: 122/255, blue: 234/255))
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 180/255, green: 120/255, blue: 80/255, opacity: 0.8),
                    Color(red: 200/255, green: 140/255, blue: 90/255, opacity: 0.7),
                    Color(red: 220/255, green: 160/255, blue: 100/255, opacity: 0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top navigation
                HStack {
                    Button(action: {
                        // Back action
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            selectedDevice = "Device 1"
                        }) {
                            Text("Device 1")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(selectedDevice == "Device 1" ? Color.white : Color.black.opacity(0.2))
                                .foregroundColor(selectedDevice == "Device 1" ? Color(red: 180/255, green: 120/255, blue: 80/255) : Color.white.opacity(0.8))
                                .cornerRadius(20)
                        }
                        
                        Button(action: {
                            selectedDevice = "Device 2"
                        }) {
                            Text("Device 2")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(selectedDevice == "Device 2" ? Color.white : Color.black.opacity(0.2))
                                .foregroundColor(selectedDevice == "Device 2" ? Color(red: 180/255, green: 120/255, blue: 80/255) : Color.white.opacity(0.8))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Title
                Text("Smart Light")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                // Light image
                ZStack {
                    // Pendant light
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 96, height: 24)
                            .cornerRadius(4, corners: [.topLeft, .topRight])
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 96, height: 8)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 96, height: 32)
                                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            
                            Capsule()
                                .fill(Color(red: 246/255, green: 224/255, blue: 94/255, opacity: 0.5))
                                .frame(width: 64, height: 4)
                                .offset(y: 12)
                        }
                    }
                }
                .frame(height: 128)
                .padding(.top, 24)
                
                Spacer()
                
                // Brightness control
                VStack {
                    ZStack {
                        Text("\(Int(brightness))%")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Brightness")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(y: 24)
                    }
                    .padding(.bottom, 24)
                    
                    // Custom slider
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 2)
                        
                        // Filled track
                        Capsule()
                            .fill(Color.white)
                            .frame(width: CGFloat(brightness) / 100 * UIScreen.main.bounds.width * 0.8, height: 2)
                        
                        // Thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat(brightness) / 100 * UIScreen.main.bounds.width * 0.8 - 10)
                    }
                    .frame(height: 48)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let width = UIScreen.main.bounds.width * 0.8
                                let percentage = min(max(0, value.location.x / width * 100), 100)
                                brightness = Double(percentage)
                            }
                    )
                }
                .padding(.horizontal, 32)
                
                // Color selection
                HStack(spacing: 16) {
                    ForEach(colorOptions, id: \.name) { colorOption in
                        Button(action: {
                            selectedColor = colorOption.name
                        }) {
                            Circle()
                                .fill(colorOption.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == colorOption.name ? 2 : 0)
                                )
                        }
                    }
                }
                .padding(.top, 48)
                
                Spacer()
                
                // Bottom navigation
                HStack {
                    Button(action: {}) {
                        Image(systemName: "house")
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Circle()
                            .fill(Color(red: 246/255, green: 224/255, blue: 94/255, opacity: 0.8))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .padding(8)
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "thermometer")
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.2))
            }
        }
        .frame(width: 300, height: 600)
        .cornerRadius(24)
    }
}

// Helper for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}



struct SmartLightControl_Previews: PreviewProvider {
    static var previews: some View {
        SmartLightControl()
    }
}
