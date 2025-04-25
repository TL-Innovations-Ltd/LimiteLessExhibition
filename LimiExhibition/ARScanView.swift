//import SwiftUI
//import RealityKit
//import ARKit
//
//// MARK: - ARScanViewContainer
//struct ARScanViewContainer: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedModel: String = "Ceiling Pendant"
//
//    var body: some View {
//        NavigationView {
//            ZStack(alignment: .top) {
//                ARScanView(selectedModel: selectedModel)
//                    .edgesIgnoringSafeArea(.all)
//
//                Menu {
//                    Button("Ceiling Pendant") { selectedModel = "Ceiling Pendant" }
//                    Button("Multiple Pendants") { selectedModel = "Multiple Pendants"}
//                    Button("Floor Lamp") { selectedModel = "Floor Lamp" }
//                    Button("Wall Light") { selectedModel = "Wall Light" }
//                } label: {
//                    Label(selectedModel, systemImage: "cube.transparent.fill")
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .background(Color.eton.opacity(0.9)) // Replace with Color.eton if defined
//                        .cornerRadius(10)
//                        .shadow(radius: 4)
//                }
//                .padding(.top, 10)
//            }
//            .navigationTitle("LIMI AR Scan")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.primary)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - ARScanView
//struct ARScanView: UIViewRepresentable {
//    var selectedModel: String
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        arView.session.run(config)
//
//        let directionalLight = DirectionalLight()
//        directionalLight.light.intensity = 70000
//        directionalLight.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
//        let lightAnchor = AnchorEntity(world: [0, 1, 0])
//        lightAnchor.addChild(directionalLight)
//        arView.scene.addAnchor(lightAnchor)
//
//        // Gestures
//        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
//        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
//        let rotate = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
//        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//
//        arView.addGestureRecognizer(tap)
//        arView.addGestureRecognizer(pinch)
//        arView.addGestureRecognizer(rotate)
//        arView.addGestureRecognizer(pan)
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        context.coordinator.currentModelName = selectedModel
//    }
//
//    class Coordinator: NSObject {
//        var parent: ARScanView
//        var currentModelName: String
//        var currentEntity: ModelEntity?
//        var totalRotation: Float = 0
//
//        init(_ parent: ARScanView) {
//            self.parent = parent
//            self.currentModelName = parent.selectedModel
//        }
//
//        @objc func handleTap(_ sender: UITapGestureRecognizer) {
//            guard let arView = sender.view as? ARView else { return }
//            let tapLocation = sender.location(in: arView)
//
//            if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
//                placeModel(in: arView, at: result)
//            }
//        }
//
//        func placeModel(in arView: ARView, at result: ARRaycastResult) {
//            arView.scene.anchors.removeAll()
//
//            guard let entity = try? ModelEntity.loadModel(named: currentModelName) else {
//                print("❌ Failed to load model: \(currentModelName)")
//                return
//            }
//
//            // Auto scale
//            let bounds = entity.visualBounds(relativeTo: nil)
//            let isFloorLamp = currentModelName.lowercased().contains("floor lamp")
//            let baseHeight = isFloorLamp ? bounds.extents.y : max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
//            let targetSize: Float = isFloorLamp ? 1.2 : 0.3  // Taller scale for lamps
//            let scaleFactor = targetSize / baseHeight
//            entity.scale = SIMD3<Float>(repeating: scaleFactor)
//
//            entity.generateCollisionShapes(recursive: true)
//
//            let anchor = AnchorEntity(world: result.worldTransform.translation)
//            anchor.addChild(entity)
//            arView.scene.addAnchor(anchor)
//
//            currentEntity = entity
//            totalRotation = 0
//        }
//
//        @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
//            guard let entity = currentEntity, sender.state == .changed else { return }
//            entity.scale *= Float(sender.scale)
//            sender.scale = 1.0
//        }
//
//        @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
//            guard let entity = currentEntity, sender.state == .changed else { return }
//            totalRotation += Float(sender.rotation)
//            entity.transform.rotation = simd_quatf(angle: totalRotation, axis: [0, 1, 0])
//            sender.rotation = 0
//        }
//
//        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
//            guard let arView = sender.view as? ARView,
//                  let entity = currentEntity,
//                  sender.state == .changed else { return }
//
//            let location = sender.location(in: arView)
//            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
//
//            if let result = results.first {
//                let newTransform = Transform(matrix: result.worldTransform)
//                entity.transform.translation = newTransform.translation
//            }
//        }
//    }
//}
//
//// MARK: - Utility Extensions
//extension simd_float4x4 {
//    var translation: SIMD3<Float> {
//        return SIMD3(columns.3.x, columns.3.y, columns.3.z)
//    }
//}
//
//extension SIMD4 {
//    var xyz: SIMD3<Scalar> { SIMD3(x, y, z) }
//}
//
//// MARK: - Preview
//struct ARScanView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARScanViewContainer()
//    }
//}
//
