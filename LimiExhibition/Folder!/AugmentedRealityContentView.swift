//
//  ContentView.swift
//  Limi
//
//  Created by Mac Mini on 14/05/2025.
//


import SwiftUI
import RealityKit
import ARKit
import Combine

struct AugmentedRealityContentView: View {
    @StateObject private var viewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Light selection panel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(LightModel.allCases, id: \.self) { light in
                            Button(action: {
                                viewModel.selectedLight = light
                            }) {
                                VStack {
                                    Image(systemName: light.iconName)
                                        .font(.system(size: 24))
                                    Text(light.displayName)
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 80)
                                .background(viewModel.selectedLight == light ? Color.blue.opacity(0.3) : Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .padding()
                
                HStack {
                    // Surface detection status
                    Text(viewModel.detectionMessage)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Screenshot button
                    Button(action: {
                        viewModel.takeScreenshot()
                    }) {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                }
                .padding()
            }
            
            // Screenshot flash and confirmation
            if viewModel.showingScreenshotEffect {
                Color.white
                    .opacity(viewModel.screenshotOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            viewModel.screenshotOpacity = 0
                        }
                    }
            }
            
            if viewModel.showingScreenshotConfirmation {
                VStack {
                    Text("Screenshot saved!")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: viewModel.showingScreenshotConfirmation)
            }
        }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    AugmentedRealityContentView()

}



struct ARViewContainer: UIViewRepresentable {
    var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.arView = arView
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        // Check if scene reconstruction is supported before enabling it
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        // Set up tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        // Set the session delegate
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = parent.viewModel.arView else { return }
            
            let tapLocation = recognizer.location(in: arView)
            parent.viewModel.placeLightModel(at: tapLocation)
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Update surface detection status
            parent.viewModel.updateSurfaceDetection(frame: frame)
        }
        
        // Add session failure handling
        func session(_ session: ARSession, didFailWithError error: Error) {
            // Handle session failures
            parent.viewModel.handleSessionFailure(error: error)
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            // Handle session interruptions
            parent.viewModel.handleSessionInterruption()
        }
    }
}

class ARViewModel: ObservableObject {
    @Published var selectedLight: LightModel = .floorLamp
    @Published var detectionMessage = "Looking for surfaces..."
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showingScreenshotEffect = false
    @Published var screenshotOpacity = 1.0
    @Published var showingScreenshotConfirmation = false
    
    weak var arView: ARView?
    private var cancellables = Set<AnyCancellable>()
    
    // Use a Set of raw values instead of dictionary with non-hashable keys
    private var detectedPlaneTypes = Set<Int>()
    
    // Load and cache models
    private var modelEntities: [LightModel: ModelEntity] = [:]
    
    func placeLightModel(at tapLocation: CGPoint) {
        guard let arView = arView else { return }
        
        // Perform ray-cast to find surface
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: selectedLight.planeAlignment)
        
        if let firstResult = results.first {
            // Check if the surface type matches the light type
            if let planeAnchor = firstResult.anchor as? ARPlaneAnchor {
                let classification = planeAnchor.classification
                
                // Verify the light can be placed on this surface type
                if !isValidPlacement(lightModel: selectedLight, classification: classification) {
                    showAlert(title: "Incorrect Surface", message: "This light should be placed on \(selectedLight.requiredSurfaceDescription)")
                    return
                }
            }
            
            // Get or load the model entity
            getModelEntity(for: selectedLight)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.showAlert(title: "Error", message: "Failed to load model: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] entity in
                    guard let self = self else { return }
                    
                    // Create anchor at the hit location
                    let anchorEntity = AnchorEntity(world: firstResult.worldTransform)
                    
                    // Remove conditional binding for non-optional value
                    let entityCopy = entity.clone(recursive: true)
                    
                    // Safely adjust orientation based on light type
                    self.adjustEntityOrientation(entityCopy, for: self.selectedLight, at: firstResult)
                    
                    // Add the entity to the anchor
                    anchorEntity.addChild(entityCopy)
                    
                    // Add the anchor to the scene on the main thread
                    DispatchQueue.main.async {
                        guard let arView = self.arView else { return }
                        arView.scene.addAnchor(anchorEntity)
                    }
                })
                .store(in: &cancellables)
        } else {
            showAlert(title: "Cannot Place Light", message: "Try pointing at a \(selectedLight.requiredSurfaceDescription)")
        }
    }
    
    private func adjustEntityOrientation(_ entity: ModelEntity, for lightModel: LightModel, at hitResult: ARRaycastResult) {
        // Added safety check
        guard entity.isEnabled else { return }
        
        switch lightModel {
        case .wallLight:
            // Orient wall lights to face away from the wall
            if let planeAnchor = hitResult.anchor as? ARPlaneAnchor {
                // Use the plane's normal vector to orient the light
                let normal = planeAnchor.transform.columns.2
                let lookAt = SIMD3<Float>(normal.x, normal.y, normal.z)
                
                // Safely apply look-at transformation
                DispatchQueue.main.async {
                    entity.look(at: lookAt, from: entity.position, relativeTo: nil)
                }
            }
        case .multiplePendants, .texturedLight:
            // Orient ceiling lights to hang down
            DispatchQueue.main.async {
                entity.transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
            }
        case .floorLamp:
            // Floor lamps should stand upright
            DispatchQueue.main.async {
                entity.transform.rotation = simd_quatf(angle: 0, axis: [0, 1, 0])
            }
        }
    }
    
    private func isValidPlacement(lightModel: LightModel, classification: ARPlaneAnchor.Classification) -> Bool {
        switch lightModel {
        case .floorLamp:
            return classification == .floor
        case .wallLight:
            return classification == .wall
        case .multiplePendants, .texturedLight:
            return classification == .ceiling
        }
    }
    
    func updateSurfaceDetection(frame: ARFrame) {
        // Reset detection status
        var hasFloor = false
        var hasWall = false
        var hasCeiling = false
        
        // Check anchors for plane types
        for anchor in frame.anchors {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { continue }
            
            switch planeAnchor.classification {
            case .floor:
                hasFloor = true
            case .wall:
                hasWall = true
            case .ceiling:
                hasCeiling = true
            default:
                break
            }
        }
        
        // Update detection message
        DispatchQueue.main.async {
            if !hasFloor && !hasWall && !hasCeiling {
                self.detectionMessage = "Looking for surfaces..."
            } else {
                var surfaces = [String]()
                if hasFloor { surfaces.append("Floor") }
                if hasWall { surfaces.append("Wall") }
                if hasCeiling { surfaces.append("Ceiling") }
                
                self.detectionMessage = "Detected: \(surfaces.joined(separator: ", "))"
            }
        }
    }
    
    func takeScreenshot() {
        guard let arView = arView else { return }
        
        // Use proper arguments for snapshot()
        arView.snapshot(saveToHDR: false) { image in
            guard let uiImage = image else {
                print("Snapshot failed")
                return
            }

            UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        // Show flash effect
        showingScreenshotEffect = true
        screenshotOpacity = 1.0
        
        // Hide flash effect after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showingScreenshotEffect = false
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save Error", message: error.localizedDescription)
        } else {
            // Show confirmation
            showingScreenshotConfirmation = true
            
            // Hide confirmation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showingScreenshotConfirmation = false
            }
        }
    }
    
    func handleSessionFailure(error: Error) {
        DispatchQueue.main.async {
            self.showAlert(title: "AR Session Failed", message: "Please restart the app: \(error.localizedDescription)")
        }
    }
    
    func handleSessionInterruption() {
        DispatchQueue.main.async {
            self.detectionMessage = "AR session interrupted"
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showingAlert = true
        }
    }
    
    private func getModelEntity(for lightModel: LightModel) -> Future<ModelEntity, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "ARViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            // Return cached model if available
            if let cachedEntity = self.modelEntities[lightModel] {
                promise(.success(cachedEntity))
                return
            }
            
            // Load model
            let modelName = lightModel.fileName
            
            // Create a URL for the model in the app bundle
            guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") else {
                promise(.failure(NSError(domain: "ARViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not found: \(modelName)"])))
                return
            }
            
            // Load the model asynchronously with error handling
            do {
                ModelEntity.loadModelAsync(contentsOf: modelURL)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    }, receiveValue: { [weak self] entity in
                        guard let self = self else {
                            promise(.success(entity))
                            return
                        }
                        
                        // Cache the loaded entity
                        DispatchQueue.main.async {
                            self.modelEntities[lightModel] = entity
                        }
                        promise(.success(entity))
                    })
                    .store(in: &self.cancellables)
            } catch {
                promise(.failure(error))
            }
        }
    }
}

enum LightModel: String, CaseIterable {
    case floorLamp = "FloorLamp"
    case multiplePendants = "MultiplePendants"
    case texturedLight = "TexturedLight"
    case wallLight = "WallLight"
    
    var fileName: String {
        return rawValue
    }
    
    var displayName: String {
        switch self {
        case .floorLamp: return "Floor Lamp"
        case .multiplePendants: return "Pendant"
        case .texturedLight: return "Ceiling"
        case .wallLight: return "Wall Light"
        }
    }
    
    var iconName: String {
        switch self {
        case .floorLamp: return "lamp.floor"
        case .multiplePendants: return "light.recessed"
        case .texturedLight: return "light.recessed"
        case .wallLight: return "light.panel"
        }
    }
    
    var planeAlignment: ARRaycastQuery.TargetAlignment {
        switch self {
        case .floorLamp:
            return .horizontal
        case .multiplePendants, .texturedLight:
            return .horizontal
        case .wallLight:
            return .vertical
        }
    }
    
    var requiredSurfaceDescription: String {
        switch self {
        case .floorLamp:
            return "floor"
        case .multiplePendants, .texturedLight:
            return "ceiling"
        case .wallLight:
            return "wall"
        }
    }
}
