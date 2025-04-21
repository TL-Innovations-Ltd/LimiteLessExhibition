//
//  ARViewContainer.swift
//  Limi
//
//  Created by Mac Mini on 08/04/2025.
//


//import SwiftUI
//import ARKit
//import RealityKit
//
//// Define your SwiftUI view
//struct ARViewContainer: View {
//    @State private var arView: ARView?
//
//    var body: some View {
//        ZStack {
//            // RealityKit ARView
//            ARViewRepresentable()
//                .edgesIgnoringSafeArea(.all)
//            
//            // Simple UI for instructions or buttons
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        print("Add model")
//                    }) {
//                        Text("Add 3D Model")
//                            .padding()
//                            .background(Color.white.opacity(0.7))
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                    }
//                    .padding()
//                }
//            }
//        }
//    }
//}
//
//// UIKit-based ARView integration
//struct ARViewRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        // Configure AR session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        arView.session.run(config)
//
//        // Add a simple box model to the scene
//        addBoxModelToScene(arView)
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        // You can update the ARView if necessary when the UI state changes
//    }
//
//    func addBoxModelToScene(_ arView: ARView) {
//        // Generate a simple 3D box model
//        let mesh = MeshResource.generateBox(size: 0.1) // 0.1 meter (10 cm) sized box
//        let material = SimpleMaterial(color: .blue, isMetallic: false) // Blue, non-metallic material
//        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
//
//        // Create an anchor entity to position the model in the AR space
//        let anchor = AnchorEntity(world: simd_float4x4(1)) // Place at the origin (0, 0, 0)
//
//        // Add the model to the anchor
//        anchor.addChild(modelEntity)
//
//        // Add the anchor to the AR scene
//        arView.scene.addAnchor(anchor)
//    }
//}
//
