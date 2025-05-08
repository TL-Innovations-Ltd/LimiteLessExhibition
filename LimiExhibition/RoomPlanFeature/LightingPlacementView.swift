////
////  LightingPlacementView.swift
////  Limi
////
////  Created by Mac Mini on 08/05/2025.
////
//
//// LightingPlacementView.swift
//import SwiftUI
//import RealityKit
//import ARKit
//import Combine
//
//struct LightingPlacementView: View {
//    @EnvironmentObject var roomDataModel: RoomDataModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedLightType: LightingFixtureType = .wallLight
//    @State private var isPlacingLight = false
//    
//    var body: some View {
//        ZStack {
//            ARViewContainer(roomDataModel: roomDataModel,
//                           selectedLightType: $selectedLightType,
//                           isPlacingLight: $isPlacingLight)
//                .ignoresSafeArea()
//            
//            VStack {
//                // Top toolbar
//                HStack {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Text("Back")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        roomDataModel.saveScan()
//                    }) {
//                        Text("Save")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.green)
//                            .cornerRadius(10)
//                    }
//                }
//                .padding()
//                
//                Spacer()
//                
//                // Bottom toolbar with lighting options
//                VStack {
//                    Text("Select Lighting Fixture")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(.top)
//                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 15) {
//                            ForEach(LightingFixtureType.allCases) { lightType in
//                                Button(action: {
//                                    selectedLightType = lightType
//                                    isPlacingLight = true
//                                }) {
//                                    VStack {
//                                        ZStack {
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .fill(Color.gray.opacity(0.3))
//                                                .frame(width: 80, height: 80)
//                                            
//                                            // In a real app, you would use actual images
//                                            Image(systemName: getLightIcon(for: lightType))
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
//                                                .frame(width: 40, height: 40)
//                                                .foregroundColor(.yellow)
//                                        }
//                                        
//                                        Text(lightType.rawValue)
//                                            .font(.caption)
//                                            .foregroundColor(.white)
//                                    }
//                                    .padding(5)
//                                    .background(selectedLightType == lightType ? Color.blue.opacity(0.5) : Color.clear)
//                                    .cornerRadius(10)
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                    .background(Color.black.opacity(0.7))
//                }
//            }
//            
//            if isPlacingLight {
//                VStack {
//                    Spacer()
//                    
//                    Text("Tap to place \(selectedLightType.rawValue)")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.black.opacity(0.7))
//                        .cornerRadius(10)
//                        .padding(.bottom, 150)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//    }
//    
//    func getLightIcon(for type: LightingFixtureType) -> String {
//        switch type {
//        case .wallLight: return "lightbulb"
//        case .ceilingLight: return "light.recessed"
//        case .floorLamp: return "lamp.floor"
//        case .tableLamp: return "lamp.desk"
//        case .pendantLight: return "light.recessed.ceiling"
//        }
//    }
//}
//
//struct ARViewContainer: UIViewRepresentable {
//    var roomDataModel: RoomDataModel
//    @Binding var selectedLightType: LightingFixtureType
//    @Binding var isPlacingLight: Bool
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        
//        // Configure AR session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        config.environmentTexturing = .automatic
//        
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
//            config.sceneReconstruction = .mesh
//        }
//        
//        arView.session.run(config)
//        
//        // Set up tap gesture
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
//                                               action: #selector(Coordinator.handleTap))
//        arView.addGestureRecognizer(tapGesture)
//        
//        context.coordinator.arView = arView
//        
//        // Add the room model if available
//        if let roomEntity = roomDataModel.roomModelEntity {
//            let anchorEntity = AnchorEntity(world: [0, 0, 0])
//            anchorEntity.addChild(roomEntity)
//            arView.scene.addAnchor(anchorEntity)
//        }
//        
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {
//        context.coordinator.selectedLightType = selectedLightType
//        context.coordinator.isPlacingLight = isPlacingLight
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(roomDataModel: roomDataModel, selectedLightType: $selectedLightType, isPlacingLight: $isPlacingLight)
//    }
//    
//    class Coordinator: NSObject {
//        var roomDataModel: RoomDataModel
//        var arView: ARView?
//        var selectedLightType: LightingFixtureType
//        @Binding var isPlacingLight: Bool
//        
//        init(roomDataModel: RoomDataModel, selectedLightType: Binding<LightingFixtureType>, isPlacingLight: Binding<Bool>) {
//            self.roomDataModel = roomDataModel
//            self._selectedLightType = selectedLightType
//            self._isPlacingLight = isPlacingLight
//            self.selectedLightType = selectedLightType.wrappedValue
//        }
//        
//        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            guard let arView = arView, isPlacingLight else { return }
//            
//            let tapLocation = gesture.location(in: arView)
//            
//            // Perform ray-casting to find where to place the light
//            let results = arView.raycast(from: tapLocation,
//                                        allowing: .estimatedPlane,
//                                        alignment: getAlignment(for: selectedLightType))
//            
//            if let firstResult = results.first {
//                // Create a new lighting fixture
//                let worldPosition = firstResult.worldTransform.columns.3
//                let position = SIMD3<Float>(worldPosition.x, worldPosition.y, worldPosition.z)
//                
//                let lightFixture = LightingFixture(type: selectedLightType, position: position)
//                
//                if let lightEntity = lightFixture.entity {
//                    // Create anchor and add to scene
//                    let anchorEntity = AnchorEntity(world: position)
//                    anchorEntity.addChild(lightEntity)
//                    arView.scene.addAnchor(anchorEntity)
//                    
//                    // Add to model
//                    roomDataModel.placedLights.append(lightFixture)
//                    
//                    // Exit placement mode
//                    isPlacingLight = false
//                }
//            }
//        }
//        
//        func getAlignment(for lightType: LightingFixtureType) -> ARRaycastQuery.TargetAlignment {
//            switch lightType {
//            case .wallLight:
//                return .vertical
//            case .ceilingLight, .pendantLight:
//                return .horizontal
//            case .floorLamp, .tableLamp:
//                return .horizontal
//            }
//        }
//    }
//}
