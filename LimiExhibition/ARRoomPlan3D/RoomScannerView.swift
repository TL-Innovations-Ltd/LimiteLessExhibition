//
//  RoomScannerView.swift
//  Limi
//
//  Created by Mac Mini on 05/05/2025.
//


import SwiftUI
import UIKit
import ARKit

// MARK: - SwiftUI Wrappers for AR View Controllers

// Wrapper for RoomScannerViewController
struct RoomScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onRoomScanned: (([SCNVector3], Float, Float) -> Void)?
    
    func makeUIViewController(context: Context) -> RoomScannerViewController {
        let viewController = RoomScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: RoomScannerViewController, context: Context) {
        // Update the view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, RoomScannerDelegate {
        var parent: RoomScannerView
        
        init(_ parent: RoomScannerView) {
            self.parent = parent
        }
        
        func roomScanningCompleted(corners: [SCNVector3], floorHeight: Float, ceilingHeight: Float) {
            parent.onRoomScanned?(corners, floorHeight, ceilingHeight)
            parent.isPresented = false
        }
        
        func roomScanningCancelled() {
            parent.isPresented = false
        }
    }
}

// Wrapper for ModelPlacementViewController
struct ModelPlacementView: UIViewControllerRepresentable {
    let roomCorners: [SCNVector3]
    let floorHeight: Float
    let ceilingHeight: Float
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> ModelPlacementViewController {
        let viewController = ModelPlacementViewController(
            roomCorners: roomCorners,
            floorHeight: floorHeight,
            ceilingHeight: ceilingHeight
        )
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ModelPlacementViewController, context: Context) {
        // Update the view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ModelPlacementDelegate {
        var parent: ModelPlacementView
        
        init(_ parent: ModelPlacementView) {
            self.parent = parent
        }
        
        func modelPlacementCompleted() {
            parent.isPresented = false
        }
        
        func modelPlacementCancelled() {
            parent.isPresented = false
        }
    }
}