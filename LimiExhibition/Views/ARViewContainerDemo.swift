//import SwiftUI
//import ARKit
//import RealityKit
//
//struct ARViewContainerDemo: View {
//    @State private var selectedModel = "sneaker_airforce"
//
//    var body: some View {
//        ZStack {
//            ARViewRepresentable(selectedModel: $selectedModel)
//                .edgesIgnoringSafeArea(.all)
//        }
//    }
//}
//
//struct ARViewRepresentable: UIViewRepresentable {
//    @Binding var selectedModel: String
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        
//        // Configure AR session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        arView.session.run(config)
//        
//        // Add coaching overlay to help users find a plane
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.session = arView.session
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        coachingOverlay.goal = .horizontalPlane
//        arView.addSubview(coachingOverlay)
//        
//        // Add tap gesture for placing models
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
//        arView.addGestureRecognizer(tapGesture)
//        
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {
//        context.coordinator.selectedModel = selectedModel
//        context.coordinator.arView = uiView
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(selectedModel: $selectedModel)
//    }
//    
//    class Coordinator: NSObject {
//        @Binding var selectedModel: String
//        var arView: ARView?
//        
//        init(selectedModel: Binding<String>) {
//            self._selectedModel = selectedModel
//        }
//        
//        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            guard let arView = arView else { return }
//            
//            // Get tap location
//            let tapLocation = gesture.location(in: arView)
//            
//            // Perform ray cast to find where user tapped
//            let results = arView.raycast(from: tapLocation,
//                                         allowing: .estimatedPlane,
//                                         alignment: .horizontal)
//            
//            // If we hit a plane, place the model
//            if let firstResult = results.first {
//                placeModel(at: firstResult.worldTransform)
//            }
//        }
//        
//        func placeModel(at transform: simd_float4x4) {
//            guard let arView = arView else { return }
//            
//            // Clear previous anchors
//            arView.scene.anchors.removeAll()
//            
//            // Create model name from selected model (replace spaces with no spaces for file name)
//            let modelFileName = selectedModel
//            
//            // Load model asynchronously
//            Task {
//                do {
//                    // Try to load the model entity
//                    guard let modelEntity = try? ModelEntity.loadModel(named: modelFileName) else {
//                        print("Failed to load model: \(modelFileName)")
//                        return
//                    }
//                    
//                    // Add physics to allow for interactions
//                    modelEntity.generateCollisionShapes(recursive: true)
//                    
//                    // Create anchor at the tap location
//                    let anchor = AnchorEntity(world: transform)
//                    anchor.addChild(modelEntity)
//                    
//                    // Add to scene
//                    arView.scene.addAnchor(anchor)
//                    
//                    print("Successfully placed model: \(modelFileName)")
//                } catch {
//                    print("Error loading model: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//// Extension to help with model loading
//extension ModelEntity {
//    static func loadModel(named modelName: String) throws -> ModelEntity {
//        // First try loading as a USDZ file
//        let modelName = modelName.hasSuffix(".usdz") ? modelName : "\(modelName).usdz"
//        
//        guard let url = Bundle.main.url(forResource: modelName, withExtension: nil) else {
//            print("Could not find model file: \(modelName)")
//            throw ModelError.modelNotFound
//        }
//        
//        do {
//            // Load the entity
//            let entity = try Entity.load(contentsOf: url)
//            
//            // Check if the loaded entity is a ModelEntity
//            if let modelEntity = entity as? ModelEntity {
//                return modelEntity
//            } else {
//                // Create a new ModelEntity and add the loaded entity as a child
//                let modelEntity = ModelEntity()
//                modelEntity.addChild(entity)
//                return modelEntity
//            }
//        } catch {
//            print("Could not load model: \(error.localizedDescription)")
//            throw ModelError.modelLoadFailed
//        }
//    }
//    
//    enum ModelError: Error {
//        case modelNotFound
//        case modelLoadFailed
//    }
//}
