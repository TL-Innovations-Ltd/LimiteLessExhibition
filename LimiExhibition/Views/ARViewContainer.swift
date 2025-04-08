//
//  ARViewContainer.swift
//  Limi
//
//  Created by Mac Mini on 08/04/2025.
//


import SwiftUI
import ARKit
import RealityKit

struct ARViewContainerDemo: View {
    @State private var selectedModel = "Ceiling Pendant"
    @State private var arView: ARView?

    // 3D models
    let models: [String: String] = [
        "Ceiling Pendant": "CeilingPendant.usdz",
        "Multiple Pendants": "MultiplePendants.usdz",
        "Floor Lamp": "FloorLamp.usdz",
        "Wall Light": "WallLight.usdz"
    ]
    
    var body: some View {
        ZStack {
            ARViewRepresentable(arView: $arView, selectedModel: $selectedModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: showModelSelection) {
                        Text("Select Model")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }
    
    // Function to show model selection
    func showModelSelection() {
        // Display model selection action sheet
        let actionSheet = UIAlertController(title: "Select 3D Model", message: nil, preferredStyle: .actionSheet)
        
        for model in models.keys {
            actionSheet.addAction(UIAlertAction(title: model, style: .default, handler: { _ in
                selectedModel = model
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(actionSheet, animated: true, completion: nil)
        }
    }
}

struct ARViewRepresentable: UIViewRepresentable {
    @Binding var arView: ARView?
    @Binding var selectedModel: String
    
    let models: [String: String] = [
        "Ceiling Pendant": "CeilingPendant.usdz",
        "Multiple Pendants": "MultiplePendants.usdz",
        "Floor Lamp": "FloorLamp.usdz",
        "Wall Light": "WallLight.usdz"
    ]
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.run(ARWorldTrackingConfiguration())
        self.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        load3DModel(uiView)
    }
    
    // Load selected 3D model
    func load3DModel(_ arView: ARView) {
        guard let modelName = models[selectedModel],
              let modelEntity = try? ModelEntity.loadModel(named: modelName) else {
            return
        }
        
        // Clear previous model if any
        arView.scene.anchors.removeAll()
        
        // Create and add anchor to the scene
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(modelEntity)
        arView.scene.addAnchor(anchor)
    }
}

