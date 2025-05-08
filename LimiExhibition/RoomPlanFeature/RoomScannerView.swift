////
////  RoomScannerView.swift
////  Limi
////
////  Created by Mac Mini on 08/05/2025.
////
//
//// RoomScannerView.swift
//import SwiftUI
//import RoomPlan
//
//struct RoomScannerView: View {
//    @EnvironmentObject var roomDataModel: RoomDataModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showLightingPlacement = false
//    
//    var body: some View {
//        ZStack {
//            RoomCaptureRepresentable(roomDataModel: roomDataModel)
//                .ignoresSafeArea()
//            
//            VStack {
//                Spacer()
//                
//                // Progress indicator
//                if roomDataModel.isScanning {
//                    ProgressView(value: roomDataModel.scanningProgress) {
//                        Text("Scanning Room: \(Int(roomDataModel.scanningProgress * 100))%")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                    }
//                    .progressViewStyle(LinearProgressViewStyle())
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//                }
//                
//                // Control buttons
//                HStack {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Text("Cancel")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.red)
//                            .cornerRadius(10)
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        if roomDataModel.isScanning {
//                            roomDataModel.isScanning = false
//                            // Proceed to lighting placement
//                            showLightingPlacement = true
//                        } else {
//                            roomDataModel.isScanning = true
//                        }
//                    }) {
//                        Text(roomDataModel.isScanning ? "Done" : "Start Scan")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    }
//                }
//                .padding()
//            }
//        }
//        .navigationBarHidden(true)
//        .fullScreenCover(isPresented: $showLightingPlacement) {
//            LightingPlacementView()
//                .environmentObject(roomDataModel)
//        }
//    }
//}
//
//struct RoomCaptureRepresentable: UIViewRepresentable {
//    var roomDataModel: RoomDataModel
//    
//    func makeUIView(context: Context) -> RoomCaptureView {
//        let roomCaptureView = RoomCaptureView(frame: .zero)
//        roomCaptureView.captureSession.delegate = context.coordinator
//        return roomCaptureView
//    }
//    
//    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
//        if roomDataModel.isScanning {
//            try? uiView.captureSession.run()
//        } else {
//            uiView.captureSession.stop()
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(roomDataModel: roomDataModel)
//    }
//    
//    class Coordinator: NSObject, RoomCaptureSessionDelegate {
//        var roomDataModel: RoomDataModel
//        
//        init(roomDataModel: RoomDataModel) {
//            self.roomDataModel = roomDataModel
//        }
//        
//        func captureSession(_ session: RoomCaptureSession, didUpdate scanInfo: RoomCaptureSession.ScanInfo) {
//            DispatchQueue.main.async {
//                self.roomDataModel.scanningProgress = scanInfo.estimatedProgress
//            }
//        }
//        
//        func captureSession(_ session: RoomCaptureSession, didEndWith result: Result<CapturedRoom, Error>) {
//            switch result {
//            case .success(let capturedRoom):
//                DispatchQueue.main.async {
//                    self.roomDataModel.capturedRoom = capturedRoom
//                    self.roomDataModel.convertCapturedRoomToEntity()
//                }
//            case .failure(let error):
//                print("Room capture failed: \(error.localizedDescription)")
//            }
//        }
//    }
////}
