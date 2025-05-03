//import SwiftUI
//import RealityKit
//import ARKit
//import Metal
//
//struct ARContentView: View {
//    @State private var selectedModelName: String = "CeilingPendant"
//    let modelNames = ["CeilingPendant", "MultiplePendants", "FloorLamp", "WallLight"]
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            ARViewContainer(selectedModelName: $selectedModelName)
//                .edgesIgnoringSafeArea(.all)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(modelNames, id: \.self) { model in
//                        Button(action: {
//                            selectedModelName = model
//                        }) {
//                            Text(model)
//                                .padding()
//                                .background(selectedModelName == model ? Color.blue : Color.white)
//                                .foregroundColor(selectedModelName == model ? .white : .black)
//                                .cornerRadius(10)
//                                .shadow(radius: 3)
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//}
//
//struct ARViewContainer: UIViewRepresentable {
//    @Binding var selectedModelName: String
//
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        // Check if Metal .metallib is available in the bundle
//        guard let metallibPath = Bundle.main.path(forResource: "default-binaryarchive", ofType: "metallib") else {
//            fatalError("❌ Could not locate default-binaryarchive.metallib in bundle.")
//        }
//
//        print("✅ Found Metal library at path: \(metallibPath)")
//
//
//        // Load Metal library from bundle
//        if let device = MTLCreateSystemDefaultDevice() {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: metallibPath))
//                let dispatchData = DispatchData(bytes: UnsafeBufferPointer(start: data.withUnsafeBytes { $0.baseAddress?.assumingMemoryBound(to: UInt8.self) }, count: data.count))
//                let _ = try device.makeLibrary(data: dispatchData)
//                print("✅ Metal library loaded successfully.")
//            } catch {
//                print("❌ Error loading Metal library: \(error)")
//            }
//        } else {
//            print("❌ Metal is not supported on this device.")
//        }
//
//        // Setup AR configuration
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        arView.session.run(config)
//
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
//        arView.addGestureRecognizer(tapGesture)
//
//        context.coordinator.arView = arView
//        context.coordinator.selectedModelName = selectedModelName
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        context.coordinator.selectedModelName = selectedModelName
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator: NSObject {
//        var arView: ARView?
//        var selectedModelName: String = ""
//
//        @objc func handleTap(_ sender: UITapGestureRecognizer) {
//            guard let arView = arView else { return }
//
//            let location = sender.location(in: arView)
//            if let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
//                let anchor = AnchorEntity(world: raycastResult.worldTransform)
//
//                let modelNameWithPath = selectedModelName + ".usdz"
//                if let modelEntity = try? ModelEntity.loadModel(named: modelNameWithPath) {
//                    modelEntity.generateCollisionShapes(recursive: true)
//                    anchor.addChild(modelEntity)
//                    arView.scene.anchors.append(anchor)
//                } else {
//                    print("❌ Failed to load model \(modelNameWithPath).")
//                }
//            }
//        }
//    }
//}

import SwiftUI
import RealityKit
import ARKit
struct CrosshairView: View {
    var body: some View {
        Circle()
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 10, height: 10)
            .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
}
struct ARViewContainer: UIViewRepresentable {
    @Binding var points: [SIMD3<Float>]

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)

        // Tap gesture for placing points
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(points: $points)
    }

    class Coordinator: NSObject {
        var arView: ARView?
        @Binding var points: [SIMD3<Float>]

        init(points: Binding<[SIMD3<Float>]>) {
            _points = points
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            let center = arView.center
            let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

            if let firstResult = results.first {
                let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x,
                                            firstResult.worldTransform.columns.3.y,
                                            firstResult.worldTransform.columns.3.z)

                points.append(position)

                // Place visual point
                let sphere = MeshResource.generateSphere(radius: 0.01)
                let material = SimpleMaterial(color: .white, isMetallic: false)
                let pointEntity = ModelEntity(mesh: sphere, materials: [material])
                pointEntity.position = position

                let anchor = AnchorEntity(world: position)
                anchor.addChild(pointEntity)
                arView.scene.addAnchor(anchor)

                print("Point added: \(position)")
                if points.count >= 2 {
                    let last = points[points.count - 1]
                    let secondLast = points[points.count - 2]
                    let distance = distanceBetween(last, and: secondLast)
                    print("Distance: \(distance) meters")
                }
            }
        }

        func distanceBetween(_ p1: SIMD3<Float>, and p2: SIMD3<Float>) -> Float {
            simd_distance(p1, p2)
        }
    }
}
struct RoomMeasureView: View {
    @State var points: [SIMD3<Float>] = []

    var body: some View {
        ZStack {
            ARViewContainer(points: $points)
                .edgesIgnoringSafeArea(.all)
            CrosshairView()
        }
    }
}
