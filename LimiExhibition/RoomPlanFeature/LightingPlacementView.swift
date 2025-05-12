// LightingPlacementView.swift
import SwiftUI
import RealityKit
import ARKit
import Combine

struct LightingPlacementView: View {
    @EnvironmentObject var roomDataModel: RoomDataModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLightType: LightingFixtureType = .wallLight
    @State private var isPlacingLight = false
    @State private var showAnimationControls = false
    @State private var selectedLightIndex: Int? = nil
    
    var body: some View {
        ZStack {
            ARViewContainer(roomDataModel: roomDataModel,
                           selectedLightType: $selectedLightType,
                           isPlacingLight: $isPlacingLight,
                           selectedLightIndex: $selectedLightIndex)
                .ignoresSafeArea()
            
            VStack {
                // Top toolbar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    if !roomDataModel.placedLights.isEmpty {
                        Button(action: {
                            showAnimationControls.toggle()
                        }) {
                            Text(showAnimationControls ? "Hide Controls" : "Animation Controls")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        roomDataModel.saveScan()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // Animation controls if visible
                if showAnimationControls {
                    VStack {
                        Text("Placed Lights")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Array(roomDataModel.placedLights.enumerated()), id: \.element.id) { index, light in
                                    Button(action: {
                                        selectedLightIndex = index
                                    }) {
                                        VStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedLightIndex == index ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                                                    .frame(width: 80, height: 80)
                                                
                                                Image(systemName: getLightIcon(for: light.type))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.yellow)
                                            }
                                            
                                            Text(light.type.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        
                        if let index = selectedLightIndex, index < roomDataModel.placedLights.count {
                            HStack {
                                Button(action: {
                                    roomDataModel.placedLights[index].startGifAnimation()
                                }) {
                                    Text("Start Animation")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    roomDataModel.placedLights[index].stopGifAnimation()
                                }) {
                                    Text("Stop Animation")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    roomDataModel.placedLights.remove(at: index)
                                    selectedLightIndex = nil
                                }) {
                                    Text("Remove")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding()
                }
                
                Spacer()
                
                // Bottom toolbar with lighting options
                VStack {
                    Text("Select Lighting Fixture")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(LightingFixtureType.allCases) { lightType in
                                Button(action: {
                                    selectedLightType = lightType
                                    isPlacingLight = true
                                }) {
                                    VStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 80, height: 80)
                                            
                                            // In a real app, you would use actual images
                                            Image(systemName: getLightIcon(for: lightType))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.yellow)
                                        }
                                        
                                        Text(lightType.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .padding(5)
                                    .background(selectedLightType == lightType ? Color.blue.opacity(0.5) : Color.clear)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                }
            }
            
            if isPlacingLight {
                VStack {
                    Spacer()
                    
                    Text("Tap to place \(selectedLightType.rawValue)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 150)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func getLightIcon(for type: LightingFixtureType) -> String {
        switch type {
        case .wallLight: return "lightbulb"
        case .ceilingLight: return "light.recessed"
        case .floorLamp: return "lamp.floor"
        case .tableLamp: return "lamp.desk"
        case .pendantLight: return "light.recessed.ceiling"
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var roomDataModel: RoomDataModel
    @Binding var selectedLightType: LightingFixtureType
    @Binding var isPlacingLight: Bool
    @Binding var selectedLightIndex: Int?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        // Set up tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        
        // Add the room model if available
        if let roomEntity = roomDataModel.roomModelEntity {
            let anchorEntity = AnchorEntity(world: [0, 0, 0])
            anchorEntity.addChild(roomEntity)
            arView.scene.addAnchor(anchorEntity)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.selectedLightType = selectedLightType
        context.coordinator.isPlacingLight = isPlacingLight
        
        // Handle selection of light for animation control
        if let index = selectedLightIndex, index < roomDataModel.placedLights.count {
            // Highlight the selected light (e.g., by changing its material temporarily)
            if let entity = roomDataModel.placedLights[index].entity {
                // Add a subtle pulsing animation to indicate selection
                if entity.transform.scale.x == 1.0 {
                    entity.transform.scale = [1.1, 1.1, 1.1]
                }
            }
        } else {
            // Reset all lights to normal scale
            for light in roomDataModel.placedLights {
                if let entity = light.entity {
                    entity.transform.scale = [1.0, 1.0, 1.0]
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(roomDataModel: roomDataModel, selectedLightType: $selectedLightType, isPlacingLight: $isPlacingLight)
    }
    
    class Coordinator: NSObject {
        var roomDataModel: RoomDataModel
        var arView: ARView?
        var selectedLightType: LightingFixtureType
        @Binding var isPlacingLight: Bool
        
        init(roomDataModel: RoomDataModel, selectedLightType: Binding<LightingFixtureType>, isPlacingLight: Binding<Bool>) {
            self.roomDataModel = roomDataModel
            self.selectedLightType = selectedLightType.wrappedValue
            self._isPlacingLight = isPlacingLight
        }
        
        // Update the property when needed
        func updateSelectedLightType(_ newType: LightingFixtureType) {
            selectedLightType = newType
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView, isPlacingLight else { return }
            
            // Get tap location
            let tapLocation = gesture.location(in: arView)
            
            // Perform ray cast to find where to place the light
            let results = arView.raycast(from: tapLocation,
                                        allowing: .estimatedPlane,
                                        alignment: .any)
            
            if let firstResult = results.first {
                // Extract position from transform matrix
                let position = SIMD3<Float>(
                    firstResult.worldTransform.columns.3.x,
                    firstResult.worldTransform.columns.3.y,
                    firstResult.worldTransform.columns.3.z
                )
                
                // Create a new lighting fixture
                let lightFixture = LightingFixture(type: selectedLightType, position: position)
                
                // Add the light to the scene
                if let lightEntity = lightFixture.entity {
                    let anchorEntity = AnchorEntity(world: SIMD3<Float>(
                        firstResult.worldTransform.columns.3.x,
                        firstResult.worldTransform.columns.3.y,
                        firstResult.worldTransform.columns.3.z
                    ))
                    anchorEntity.addChild(lightEntity)
                    arView.scene.addAnchor(anchorEntity)
                    
                    // Add to the model
                    DispatchQueue.main.async {
                        self.roomDataModel.placedLights.append(lightFixture)
                        self.isPlacingLight = false
                        
                        // Start the animation automatically for the new light
                        lightFixture.startGifAnimation()
                    }
                }
            }
        }
    }
}
