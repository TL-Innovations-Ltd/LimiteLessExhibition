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
            } catch {
                print("Error saving room scan: \(error.localizedDescription)")
            }
        }
    }
}
