//
//  HubsListView.swift
//  Limi
//
//  Created by Mac Mini on 18/04/2025.
//


import SwiftUI
// MARK: - Hubs List Component
struct HubsListView: View {
    var isLoaded: Bool
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(Array(bluetoothManager.storedHubs.enumerated()), id: \.element.id) { index, hub in
                NavigationLink(destination: HomeDetailView(hub: hub)) {
                    HubCardView(hub: hub, bluetoothManager: bluetoothManager)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .offset(x: isLoaded ? 0 : 300)
                        .opacity(isLoaded ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1 + 0.3),
                            value: isLoaded
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}