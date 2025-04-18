//
//  SpacesListView.swift
//  Limi
//
//  Created by Mac Mini on 18/04/2025.
//


import SwiftUI

// MARK: - Spaces List Component
struct SpacesListView: View {
    var demoEmail: String
    @Binding var isLoaded: Bool
    @Binding var isNavigatingToAddDevice: Bool
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Spaces")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charlestonGreen)
            }
            .padding(.horizontal, 5)
            .padding(.top, 15)
            .opacity(isLoaded ? 1 : 0)
            .animation(.easeIn.delay(0.3), value: isLoaded)
            
            if demoEmail == "umer.asif@terralumen.co.uk" {
                DemoHubsListView(isLoaded: isLoaded, bluetoothManager: bluetoothManager)
            } else {
                if bluetoothManager.storedHubs.isEmpty {
                    EmptyStateView(isLoaded: isLoaded, isNavigatingToAddDevice: $isNavigatingToAddDevice)
                } else {
                    HubsListView(isLoaded: isLoaded, bluetoothManager: bluetoothManager)
                }
            }
        }
        .onAppear {
            isLoaded = true
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fullScreenCover(isPresented: $isNavigatingToAddDevice) {
            AddDeviceView()
        }
    }
}