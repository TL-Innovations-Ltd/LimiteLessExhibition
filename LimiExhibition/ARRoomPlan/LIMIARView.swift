import SwiftUI
import ARKit
import RoomPlan
import RealityKit
import Combine

// Main coordinator for the AR experience
class ARCoordinator: NSObject, ObservableObject, RoomCaptureSessionDelegate {
    @Published var scanningComplete = false
    @Published var roomCaptureSession: RoomCaptureSession?
    @Published var arSession = ARSession()
    @Published var selectedModel: LIMIProductModel = .ceilingPendant
    @Published var placedModels: [PlacedModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupARSession()
    }
    
    func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        arSession.run(configuration)
    }
    
    func startRoomCapture() {
        let roomCaptureSession = RoomCaptureSession()
        roomCaptureSession.delegate = self
        self.roomCaptureSession = roomCaptureSession
        
        // Create configuration for room capture
        let configuration = RoomCaptureSession.Configuration()
        
        // Start the room capture session with configuration
        roomCaptureSession.run(configuration: configuration)
    }
    
    func finishRoomCapture() {
        roomCaptureSession?.stop()
        scanningComplete = true
    }
    
    // RoomCaptureSessionDelegate methods
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        // Process room updates if needed
    }
    
    func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
        // Process room additions if needed
    }
    
    func captureSession(_ session: RoomCaptureSession, didRemove room: CapturedRoom) {
        // Process room removals if needed
    }
    
    func placeModel(at position: SIMD3<Float>, on surface: ARPlaneAnchor.Alignment) {
        // Check if the selected model is compatible with the detected surface
        guard isModelCompatibleWithSurface(model: selectedModel, surface: surface) else {
            print("Model not compatible with this surface type")
            return
        }
        
        let modelEntity = createModelEntity(for: selectedModel)
        let placedModel = PlacedModel(id: UUID(), model: selectedModel, position: position, entity: modelEntity)
        placedModels.append(placedModel)
    }
    
    private func isModelCompatibleWithSurface(model: LIMIProductModel, surface: ARPlaneAnchor.Alignment) -> Bool {
        // Check if we're dealing with a ceiling (horizontal plane with normal pointing down)
        let isCeiling = surface == .horizontal && arSession.currentFrame?.camera.transform.columns.1.y ?? 0 < 0
        
        switch (model, surface, isCeiling) {
        case (.ceilingPendant, .horizontal, true), (.multiplePendants, .horizontal, true):
            return true
        case (.floorLamp, .horizontal, false):
            return true
        case (.wallLight, .vertical, _):
            return true
        default:
            return false
        }
    }
    
    private func createModelEntity(for model: LIMIProductModel) -> ModelEntity {
        // In a real app, you would load the actual 3D model here
        // For this example, we're creating placeholder entities
        let modelEntity = ModelEntity()
        
        // Configure the entity based on the model type
        switch model {
        case .ceilingPendant:
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let material = SimpleMaterial(color: .white, roughness: 0.5, isMetallic: true)
            modelEntity.model = ModelComponent(mesh: mesh, materials: [material])
            
        case .multiplePendants:
            let mesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .white, roughness: 0.5, isMetallic: true)
            modelEntity.model = ModelComponent(mesh: mesh, materials: [material])
            
            // Add child entities for multiple pendants
            for i in 0..<3 {
                let childEntity = ModelEntity(mesh: mesh, materials: [material])
                childEntity.position = SIMD3<Float>(Float(i) * 0.1 - 0.1, -0.2, 0)
                modelEntity.addChild(childEntity)
            }
            
        case .floorLamp:
            let baseMesh = MeshResource.generateBox(size: [0.2, 0.02, 0.2])
            let poleMesh = MeshResource.generateBox(size: [0.02, 1.5, 0.02])
            let lampMesh = MeshResource.generateSphere(radius: 0.1)
            
            let metalMaterial = SimpleMaterial(color: .gray, roughness: 0.3, isMetallic: true)
            let lampMaterial = SimpleMaterial(color: .white, roughness: 0.5, isMetallic: false)
            
            let baseEntity = ModelEntity(mesh: baseMesh, materials: [metalMaterial])
            let poleEntity = ModelEntity(mesh: poleMesh, materials: [metalMaterial])
            let lampEntity = ModelEntity(mesh: lampMesh, materials: [lampMaterial])
            
            poleEntity.position = [0, 0.75, 0]
            lampEntity.position = [0, 1.5, 0]
            
            modelEntity.addChild(baseEntity)
            modelEntity.addChild(poleEntity)
            modelEntity.addChild(lampEntity)
            
        case .wallLight:
            let baseMesh = MeshResource.generateBox(size: [0.1, 0.2, 0.05])
            let lampMesh = MeshResource.generateSphere(radius: 0.08)
            
            let metalMaterial = SimpleMaterial(color: .gray, roughness: 0.3, isMetallic: true)
            let lampMaterial = SimpleMaterial(color: .white, roughness: 0.5, isMetallic: false)
            
            let baseEntity = ModelEntity(mesh: baseMesh, materials: [metalMaterial])
            let lampEntity = ModelEntity(mesh: lampMesh, materials: [lampMaterial])
            
            lampEntity.position = [0, 0, 0.1]
            
            modelEntity.addChild(baseEntity)
            modelEntity.addChild(lampEntity)
        }
        
        // Add light using a light component that's compatible with RealityKit
        if let lightComponent = try? PointLightComponent(
            color: .white,
            intensity: 500,
            attenuationRadius: 0.5
        ) {
            modelEntity.components[PointLightComponent.self] = lightComponent
        }
        
        return modelEntity
    }
    
    func updateModelPosition(id: UUID, position: SIMD3<Float>) {
        if let index = placedModels.firstIndex(where: { $0.id == id }) {
            placedModels[index].position = position
        }
    }
    
    func updateModelRotation(id: UUID, rotation: simd_quatf) {
        if let index = placedModels.firstIndex(where: { $0.id == id }) {
            placedModels[index].entity.orientation = rotation
        }
    }
    
    func updateModelScale(id: UUID, scale: Float) {
        if let index = placedModels.firstIndex(where: { $0.id == id }) {
            placedModels[index].entity.scale = SIMD3<Float>(repeating: scale)
        }
    }
    
    func removeModel(id: UUID) {
        placedModels.removeAll(where: { $0.id == id })
    }
}

// Model representing a placed 3D object
struct PlacedModel: Identifiable {
    let id: UUID
    let model: LIMIProductModel
    var position: SIMD3<Float>
    let entity: ModelEntity
}

// Available LIMI product models
enum LIMIProductModel: String, CaseIterable, Identifiable {
    case ceilingPendant = "Ceiling Pendant"
    case multiplePendants = "Multiple Pendants"
    case floorLamp = "Floor Lamp"
    case wallLight = "Wall Light"
    
    var id: String { self.rawValue }
    
    var surfaceCompatibility: String {
        switch self {
        case .ceilingPendant, .multiplePendants:
            return "Ceiling"
        case .floorLamp:
            return "Floor"
        case .wallLight:
            return "Wall"
        }
    }
    
    var thumbnail: String {
        switch self {
        case .ceilingPendant:
            return "light.pendant"
        case .multiplePendants:
            return "light.recessed"
        case .floorLamp:
            return "lamp.floor"
        case .wallLight:
            return "light.recessed.rectangle"
        }
    }
}

// Main SwiftUI view for the AR experience
struct LIMIARView: View {
    @StateObject private var coordinator = ARCoordinator()
    @State private var showModelPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            if !coordinator.scanningComplete {
                // Use a custom view that creates a RoomCaptureView when needed
                RoomScannerView(coordinator: coordinator)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Spacer()
                            Button(action: {
                                coordinator.finishRoomCapture()
                            }) {
                                Text("Finish Scanning")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 50)
                        }
                    )
                    .onAppear {
                        coordinator.startRoomCapture()
                    }
            } else {
                ARSceneView(coordinator: coordinator)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showModelPicker.toggle()
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            
                            Spacer()
                            
                            if showModelPicker {
                                ModelPickerView(selectedModel: $coordinator.selectedModel, isShowing: $showModelPicker)
                                    .transition(.move(edge: .bottom))
                            }
                        }
                    )
            }
        }
        .navigationBarHidden(true)
    }
}

// SwiftUI wrapper for RoomCaptureView
struct RoomScannerView: UIViewControllerRepresentable {
    var coordinator: ARCoordinator
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Create a container view controller
        let containerViewController = UIViewController()
        
        // Check if we have a valid session
        if let session = coordinator.roomCaptureSession {
            // Create the RoomCaptureView with the session
            let roomCaptureView = RoomCaptureView(frame: containerViewController.view.bounds)
            
            // Since we can't set captureSession directly (it's read-only),
            // we need to create a new RoomCaptureSession and configure it
            // This is a workaround since we can't directly set the session
            
            // Add the room capture view to the container
            containerViewController.view.addSubview(roomCaptureView)
            
            // Make the room capture view fill the container
            roomCaptureView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                roomCaptureView.topAnchor.constraint(equalTo: containerViewController.view.topAnchor),
                roomCaptureView.bottomAnchor.constraint(equalTo: containerViewController.view.bottomAnchor),
                roomCaptureView.leadingAnchor.constraint(equalTo: containerViewController.view.leadingAnchor),
                roomCaptureView.trailingAnchor.constraint(equalTo: containerViewController.view.trailingAnchor)
            ])
        }
        
        return containerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update here since we can't change the session
    }
}

// SwiftUI wrapper for ARView
struct ARSceneView: UIViewRepresentable {
    var coordinator: ARCoordinator
    
    func makeUIView(context: Context) -> RealityKit.ARView {
        let arView = RealityKit.ARView(frame: .zero)
        arView.session = coordinator.arSession
        
        // Configure the AR view
        arView.environment.lighting.intensityExponent = 1.0
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        // Add tap gesture for model placement
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Add pan gesture for model movement
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        // Add rotation gesture
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
        
        // Add pinch gesture for scaling
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: RealityKit.ARView, context: Context) {
        // Update the AR view with placed models
        updatePlacedModels(in: uiView)
    }
    
    private func updatePlacedModels(in arView: RealityKit.ARView) {
        // Remove all anchors
        arView.scene.anchors.removeAll()
        
        // Add anchors for each placed model
        for placedModel in coordinator.placedModels {
            let anchor = AnchorEntity(world: placedModel.position)
            anchor.addChild(placedModel.entity)
            arView.scene.addAnchor(anchor)
        }
    }
    
    class Coordinator: NSObject {
        var parent: ARSceneView
        var selectedModelEntity: ModelEntity?
        
        init(parent: ARSceneView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? RealityKit.ARView else { return }
            
            let location = gesture.location(in: arView)
            
            // Perform hit test to find surfaces
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            
            if let firstResult = results.first {
                // Get the alignment of the surface
                let alignment: ARPlaneAnchor.Alignment
                
                if firstResult.worldTransform.columns.1.y > 0.9 {
                    alignment = .horizontal
                } else if firstResult.worldTransform.columns.1.y < -0.9 {
                    alignment = .horizontal // This is a ceiling (horizontal plane with normal pointing down)
                } else {
                    alignment = .vertical
                }
                
                // Place the model at the hit location
                let position = simd_make_float3(firstResult.worldTransform.columns.3)
                parent.coordinator.placeModel(at: position, on: alignment)
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = gesture.view as? RealityKit.ARView else { return }
            
            let location = gesture.location(in: arView)
            
            switch gesture.state {
            case .began:
                // Perform hit test to find if we're touching a model
                let results = arView.hitTest(location)
                if let result = results.first, let entity = result.entity.parent as? ModelEntity {
                    if let index = parent.coordinator.placedModels.firstIndex(where: { $0.entity == entity }) {
                        selectedModelEntity = entity
                    }
                }
                
            case .changed:
                guard selectedModelEntity != nil else { return }
                
                // Perform raycast to find where on the plane the user is dragging
                let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
                
                if let firstResult = results.first {
                    let position = simd_make_float3(firstResult.worldTransform.columns.3)
                    
                    // Find the model and update its position
                    if let index = parent.coordinator.placedModels.firstIndex(where: { $0.entity == selectedModelEntity }) {
                        parent.coordinator.updateModelPosition(id: parent.coordinator.placedModels[index].id, position: position)
                    }
                }
                
            case .ended, .cancelled:
                selectedModelEntity = nil
                
            default:
                break
            }
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let arView = gesture.view as? RealityKit.ARView, selectedModelEntity != nil else { return }
            
            switch gesture.state {
            case .changed:
                // Convert the rotation to a quaternion around the y-axis
                let rotation = simd_quatf(angle: Float(gesture.rotation), axis: [0, 1, 0])
                
                // Find the model and update its rotation
                if let index = parent.coordinator.placedModels.firstIndex(where: { $0.entity == selectedModelEntity }) {
                    parent.coordinator.updateModelRotation(id: parent.coordinator.placedModels[index].id, rotation: rotation)
                }
                
                // Reset the gesture rotation to avoid accumulation
                gesture.rotation = 0
                
            default:
                break
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let arView = gesture.view as? RealityKit.ARView, selectedModelEntity != nil else { return }
            
            switch gesture.state {
            case .changed:
                let scale = Float(gesture.scale)
                
                // Find the model and update its scale
                if let index = parent.coordinator.placedModels.firstIndex(where: { $0.entity == selectedModelEntity }) {
                    parent.coordinator.updateModelScale(id: parent.coordinator.placedModels[index].id, scale: scale)
                }
                
                // Reset the gesture scale to avoid accumulation
                gesture.scale = 1.0
                
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

// View for selecting LIMI product models
struct ModelPickerView: View {
    @Binding var selectedModel: LIMIProductModel
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Text("Select a LIMI Product")
                .font(.headline)
                .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(LIMIProductModel.allCases) { model in
                        VStack {
                            Image(systemName: model.thumbnail)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .padding()
                                .background(selectedModel == model ? Color.blue : Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedModel = model
                                    isShowing = false
                                }
                            
                            Text(model.rawValue)
                                .font(.caption)
                            
                            Text(model.surfaceCompatibility)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 150)
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .padding()
        }
    }
}
