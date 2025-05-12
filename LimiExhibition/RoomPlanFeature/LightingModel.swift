// LightingModel
import Foundation
import RealityKit
import Combine
import UIKit

enum LightingFixtureType: String, CaseIterable, Identifiable {
    case wallLight = "Wall Light"
    case ceilingLight = "Ceiling Light"
    case floorLamp = "Floor Lamp"
    case tableLamp = "Table Lamp"
    case pendantLight = "Pendant Light"
    
    var id: String { self.rawValue }
    
    var modelName: String {
        switch self {
        case .wallLight: return "wallLight"
        case .ceilingLight: return "ceilingLight"
        case .floorLamp: return "floorLamp"
        case .tableLamp: return "tableLamp"
        case .pendantLight: return "pendantLight"
        }
    }
    
    var thumbnailName: String {
        return "\(modelName)_thumbnail"
    }
    
    // Add GIF name for each fixture type
    var gifName: String {
        return "\(modelName)_animation"
    }
}

class LightingFixture: Identifiable {
    let id = UUID()
    let type: LightingFixtureType
    var entity: ModelEntity?
    var position: SIMD3<Float>
    var cancellables = Set<AnyCancellable>()
    var animationTimer: Timer?
    var gifFrames: [UIImage] = []
    var currentFrameIndex = 0
    
    init(type: LightingFixtureType, position: SIMD3<Float> = [0, 0, 0]) {
        self.type = type
        self.position = position
        loadModel()
        loadGifAnimation()
    }
    
    private func loadModel() {
        // In a real app, you would load actual 3D models from your app bundle
        // For this example, we'll create simple geometric shapes
        
        var modelEntity: ModelEntity
        
        switch type {
        case .wallLight:
            modelEntity = ModelEntity(mesh: .generateBox(size: 0.2))
        case .ceilingLight:
            modelEntity = ModelEntity(mesh: .generateSphere(radius: 0.15))
        case .floorLamp:
            let base = ModelEntity(mesh: .generateCylinder(height: 1.2, radius: 0.1))
            let lampHead = ModelEntity(mesh: .generateSphere(radius: 0.15))
            lampHead.position = [0, 0.6, 0]
            base.addChild(lampHead)
            modelEntity = base
        case .tableLamp:
            let base = ModelEntity(mesh: .generateCylinder(height: 0.5, radius: 0.1))
            let lampHead = ModelEntity(mesh: .generateSphere(radius: 0.12))
            lampHead.position = [0, 0.25, 0]
            base.addChild(lampHead)
            modelEntity = base
        case .pendantLight:
            let cord = ModelEntity(mesh: .generateCylinder(height: 0.8, radius: 0.02))
            let lampHead = ModelEntity(mesh: .generateCone(height: 0.25, radius: 0.15))
            lampHead.position = [0, -0.4, 0]
            cord.addChild(lampHead)
            modelEntity = cord
        }
        
        // Add light component
        let light = PointLightComponent(color: .white,
                                       intensity: 5000.0,
                                       attenuationRadius: 5.0)
        modelEntity.components.set(light)
        
        // Add material
        var material = SimpleMaterial(color: .yellow, roughness: 0.5, isMetallic: false)
        modelEntity.model?.materials = [material]
        
        self.entity = modelEntity
    }
    
    private func loadGifAnimation() {
        // In a real app, you would load the GIF from your bundle
        // For this example, we'll simulate loading frames
        
        // Simulated GIF frames with different colors to represent animation
        let colors: [UIColor] = [.yellow, .orange, .red, .orange, .yellow]
        
        for color in colors {
            // Create a colored image to represent a frame
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
            let image = renderer.image { ctx in
                color.setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
            }
            gifFrames.append(image)
        }
        
        // Start animation
        startGifAnimation()
    }
    
    func startGifAnimation() {
        // Stop any existing animation
        stopGifAnimation()
        
        // Create a timer to cycle through frames
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Update to next frame
            self.currentFrameIndex = (self.currentFrameIndex + 1) % self.gifFrames.count
            
            // Apply the frame to the entity
            self.updateEntityWithCurrentFrame()
        }
    }
    
    func stopGifAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateEntityWithCurrentFrame() {
        guard let entity = entity, !gifFrames.isEmpty else { return }
        
        // Get current frame
        let frame = gifFrames[currentFrameIndex]
        
        // Convert UIImage to material
        let texture = try? TextureResource.generate(from: frame.cgImage!,
                                                  options: .init(semantic: .color))
        
        if let texture = texture {
            var material = SimpleMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            material.roughness = 0.5
            material.metallic = 0.0
            
            // Apply the material
            entity.model?.materials = [material]
            
            // Also update the light color to match the frame
            if let light = entity.components[PointLightComponent.self] {
                // Extract dominant color from the frame
                let dominantColor = extractDominantColor(from: frame)
                var updatedLight = light
                updatedLight.color = dominantColor
                entity.components.set(updatedLight)
            }
        }
    }
    
    private func extractDominantColor(from image: UIImage) -> UIColor {
        // In a real app, you would implement a proper algorithm to extract the dominant color
        // For this example, we'll use a simple approach based on our simulated frames
        
        let index = currentFrameIndex % 5
        switch index {
        case 0, 4: return .yellow
        case 1, 3: return .orange
        case 2: return .red
        default: return .white
        }
    }
    
    func updatePosition(_ newPosition: SIMD3<Float>) {
        position = newPosition
        entity?.position = newPosition
    }
    
    deinit {
        stopGifAnimation()
    }
}

// Extension to load GIF data
extension Data {
    func decodeGif() -> [UIImage]? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
        }
        
        return images
    }
}
