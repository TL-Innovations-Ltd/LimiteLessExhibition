//
//  HubCardContent.swift
//  Limi
//
//  Created by Mac Mini on 18/04/2025.
//


import SwiftUI
// MARK: - Hub Card Content Component
struct HubCardContent: View {
    let hub: Hub
    var pulseAnimation: Bool
    var isExpanded: Bool
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.etonBlue.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulseAnimation ? 1.2 : 0.9)
                    .opacity(pulseAnimation ? 0.6 : 0.2)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.etonBlue.opacity(0.8), Color.etonBlue.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                Image(systemName: "house.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bluetoothManager.connectedDeviceName ?? hub.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.charlestonGreen)
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .opacity(pulseAnimation ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )
                    Text("Connected")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .foregroundColor(.emerald.opacity(0.8))
        }
        .padding()
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.white, .alabaster.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}