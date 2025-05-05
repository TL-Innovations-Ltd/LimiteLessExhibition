//
//  ARScanView.swift
//  Limi
//
//  Created by Mac Mini on 05/05/2025.
//


import SwiftUI
import SceneKit

struct ARScanView: View {
    @StateObject private var viewModel = ARViewModel()
    
    var body: some View {
        VStack {
            // Your main content here
            Button("Start AR Room Scan") {
                viewModel.showARScan = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $viewModel.showARScan) {
            // This is where we use our SwiftUI wrapper for the AR scanning
            RoomScannerView(isPresented: $viewModel.showARScan) { corners, floorHeight, ceilingHeight in
                // Store the room data
                viewModel.roomCorners = corners
                viewModel.floorHeight = floorHeight
                viewModel.ceilingHeight = ceilingHeight
                
                // Show the model placement view
                viewModel.showModelPlacement = true
            }
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $viewModel.showModelPlacement) {
            // Only show this if we have room data
            if !viewModel.roomCorners.isEmpty {
                ModelPlacementView(
                    roomCorners: viewModel.roomCorners,
                    floorHeight: viewModel.floorHeight,
                    ceilingHeight: viewModel.ceilingHeight,
                    isPresented: $viewModel.showModelPlacement
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

// ViewModel to manage AR state
class ARViewModel: ObservableObject {
    @Published var showARScan = false
    @Published var showModelPlacement = false
    
    // Room data
    var roomCorners: [SCNVector3] = []
    var floorHeight: Float = 0
    var ceilingHeight: Float = 0
}
