////
////  LightingModel.swift
////  Limi
////
////  Created by Mac Mini on 08/05/2025.
////
//
//// LightingModel.swift
//import Foundation
//import RealityKit
//import Combine
//
//enum LightingFixtureType: String, CaseIterable, Identifiable {
//    case wallLight = "Wall Light"
//    case ceilingLight = "Ceiling Light"
//    case floorLamp = "Floor Lamp"
//    case tableLamp = "Table Lamp"
//    case pendantLight = "Pendant Light"
//    
//    var id: String { self.rawValue }
//    
//    var modelName: String {
//        switch self {
//        case .wallLight: return "wallLight"
//        case .ceilingLight: return "ceilingLight"
//        case .floorLamp: return "floorLamp"
//        case .tableLamp: return "tableLamp"
//        case .pendantLight: return "pendantLight"
//        }
//    }
//    
//    var thumbnailName: String {
//        return "\(modelName)_thumbnail"
//    }
//}
//
//class LightingFixture: Identifiable {
//    let id = UUID()
//    let type: LightingFixtureType
//    var entity: ModelEntity?
//    var position: SIMD3<Float>
//    var cancellables = Set<AnyCancellable>()
//    
//    init(type: LightingFixtureType, position: SIMD3<Float> = [0, 0, 0]) {
//        self.type = type
//        self.position = position
//        loadModel()
//    }
//    
//    private func loadModel() {
//        // In a real app, you would load actual 3D models from your app bundle
//        // For this example, we'll create simple geometric shapes
//        
//        var modelEntity: ModelEntity
//        
//        switch type {
//        case .wallLight:
//            modelEntity = ModelEntity(mesh: .generateBox(size: 0.2))
//        case .ceilingLight:
//            modelEntity = ModelEntity(mesh: .generateSphere(radius: 0.15))
//        case .floorLamp:
//            let base = ModelEntity(mesh: .generateCylinder(height: 1.2, radius: 0.1))
//            let lampHead = ModelEntity(mesh: .generateSphere(radius: 0.15))
//            lampHead.position = [0, 0.6, 0]
//            base.addChild(lampHead)
//            modelEntity = base
//        case .tableLamp:
//            let base = ModelEntity(mesh: .generateCylinder(height: 0.5, radius: 0.1))
//            let lampHead = ModelEntity(mesh: .generateSphere(radius: 0.12))
//            lampHead.position = [0, 0.25, 0]
//            base.addChild(lampHead)
//            modelEntity = base
//        case .pendantLight:
//            let cord = ModelEntity(mesh: .generateCylinder(height: 0.8, radius: 0.02))
//            let lampHead = ModelEntity(mesh: .generateCone(height: 0.25, radius: 0.15))
//            lampHead.position = [0, -0.4, 0]
//            cord.addChild(lampHead)
//            modelEntity = cord
//        }
//        
//        // Add light component
//        let light = PointLightComponent(color: .white,
//                                       intensity: 5000.0,
//                                       attenuationRadius: 5.0)
//        modelEntity.components.set(light)
//        
//        // Add material
//        var material = SimpleMaterial(color: .yellow, roughness: 0.5, isMetallic: false)
//        modelEntity.model?.materials = [material]
//        
//        self.entity = modelEntity
//    }
//    
//    func updatePosition(_ newPosition: SIMD3<Float>) {
//        position = newPosition
//        entity?.position = newPosition
//    }
//}
