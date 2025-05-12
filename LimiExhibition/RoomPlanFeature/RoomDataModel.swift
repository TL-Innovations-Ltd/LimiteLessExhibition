// RoomDataModel.swift
import Foundation
import RoomPlan
import RealityKit

class RoomDataModel: ObservableObject {
    @Published var capturedRoom: CapturedRoom?
    @Published var roomModelEntity: ModelEntity?
    @Published var isScanning = false
    @Published var scanningProgress: Float = 0.0
    @Published var placedLights: [LightingFixture] = []
    
    func convertCapturedRoomToEntity() {
        guard let capturedRoom = capturedRoom else { return }
        
        // Create a ModelEntity from the CapturedRoom
        Task {
            do {
                let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("room.usdz")
                try await capturedRoom.export(to: destinationURL)
                let roomEntity = try await ModelEntity.loadModel(contentsOf: destinationURL)
                
                DispatchQueue.main.async {
                    self.roomModelEntity = roomEntity
                }
            } catch {
                print("Error converting room: \(error.localizedDescription)")
            }
        }
    }
    
    func saveScan() {
        guard let capturedRoom = capturedRoom else { return }
        
        Task {
            do {
                let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("RoomScan_\(Date().timeIntervalSince1970).usdz")
                try await capturedRoom.export(to: destinationURL)
                print("Room scan saved to: \(destinationURL.path)")
                
                // Also save information about placed lights
                savePlacedLightsInfo()
            } catch {
                print("Error saving room scan: \(error.localizedDescription)")
            }
        }
    }
    
    private func savePlacedLightsInfo() {
        // Create a dictionary to store light information
        var lightsInfo: [[String: Any]] = []
        
        for light in placedLights {
            let lightInfo: [String: Any] = [
                "type": light.type.rawValue,
                "position": [
                    "x": light.position.x,
                    "y": light.position.y,
                    "z": light.position.z
                ]
            ]
            lightsInfo.append(lightInfo)
        }
        
        // Convert to JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: lightsInfo, options: .prettyPrinted) {
            let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("LightsInfo_\(Date().timeIntervalSince1970).json")
            
            do {
                try jsonData.write(to: destinationURL)
                print("Lights info saved to: \(destinationURL.path)")
            } catch {
                print("Error saving lights info: \(error.localizedDescription)")
            }
        }
    }
    
    // Method to load GIF data for a specific light type
    func loadGifData(for lightType: LightingFixtureType) -> Data? {
        // In a real app, you would load the GIF from your bundle
        // For this example, we'll return nil
        return nil
    }
    
    // Method to start animations for all lights
    func startAllAnimations() {
        for light in placedLights {
            light.startGifAnimation()
        }
    }
    
    // Method to stop animations for all lights
    func stopAllAnimations() {
        for light in placedLights {
            light.stopGifAnimation()
        }
    }
}
