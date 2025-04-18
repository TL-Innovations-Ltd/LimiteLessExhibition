//
//  DemoHubsListView.swift
//  Limi
//
//  Created by Mac Mini on 18/04/2025.
//


import SwiftUI
// MARK: - Demo Hubs List Component
struct DemoHubsListView: View {
    var isLoaded: Bool
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(Array(bluetoothManager.DemostoredHubs.enumerated()), id: \.element.id) { index, hub in
                HubRowView(hub: hub, index: index, isLoaded: isLoaded, bluetoothManager: bluetoothManager)
            }
        }
        .onAppear {
            // Any setup needed for demo hubs
        }
    }
}