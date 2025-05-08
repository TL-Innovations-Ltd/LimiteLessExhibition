////
////  RoomDataModel.swift
////  Limi
////
////  Created by Mac Mini on 08/05/2025.
////
//
//// RoomDataModel.swift
//import Foundation
//import RoomPlan
//import RealityKit
//
//class RoomDataModel: ObservableObject {
//    @Published var capturedRoom: CapturedRoom?
//    @Published var roomModelEntity: ModelEntity?
//    @Published var isScanning = false
//    @Published var scanningProgress: Float = 0.0
//    @Published var placedLights: [LightingFixture] = []
//    
//    func convertCapturedRoomToEntity() {
//        guard let capturedRoom = capturedRoom else { return }
//        
//        // Create a ModelEntity from the CapturedRoom
//        Task {
//            do {
//                let roomModel = try await capturedRoom.export(to: .usdz)
//                let roomEntity = try await ModelEntity.loadModel(contentsOf: roomModel)
//                
//                DispatchQueue.main.async {
//                    self.roomModelEntity = roomEntity
//                }
//            } catch {
//                print("Error converting room: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func saveScan() {
//        guard let capturedRoom = capturedRoom else { return }
//        
//        Task {
//            do {
//                let roomModel = try await capturedRoom.export(to: .usdz)
//                let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("RoomScan_\(Date().timeIntervalSince1970).usdz")
//                
//                try FileManager.default.copyItem(at: roomModel, to: destinationURL)
//                print("Room scan saved to: \(destinationURL.path)")
//            } catch {
//                print("Error saving room scan: \(error.localizedDescription)")
//            }
//        }
//    }
//}
