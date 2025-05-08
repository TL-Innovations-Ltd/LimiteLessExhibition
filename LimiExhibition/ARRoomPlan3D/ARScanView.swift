//import SwiftUI
//import SceneKit
//
//struct ARScanView: View {
//    @StateObject private var viewModel = ARViewModel()
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        ZStack {
//            // Background
//            (colorScheme == .dark ? Color.black : Color(UIColor.systemGray6))
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 30) {
//                // Header
//                VStack(spacing: 15) {
//                    Text("AR Room Scanner")
//                        .font(.system(size: 32, weight: .bold))
//                        .foregroundColor(colorScheme == .dark ? .white : .black)
//                    
//                    Text("Scan your room and place 3D models")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 20)
//                }
//                .padding(.top, 50)
//                
//                Spacer()
//                
//                // Room illustration
//                Image(systemName: "cube.transparent")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 120, height: 120)
//                    .foregroundColor(.blue)
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.blue.opacity(0.1))
//                            .frame(width: 200, height: 200)
//                    )
//                
//                // Features list
//                VStack(alignment: .leading, spacing: 12) {
//                    FeatureRow(icon: "ruler", text: "Accurate room measurements")
//                    FeatureRow(icon: "cube.box", text: "Place 3D models in your space")
//                    FeatureRow(icon: "rotate.3d", text: "Rotate and scale objects")
//                    FeatureRow(icon: "light.max", text: "Visualize lighting fixtures")
//                }
//                .padding(.horizontal, 30)
//                .padding(.vertical, 20)
//                
//                Spacer()
//                
//                // Start button
//                Button(action: {
//                    viewModel.showARScan = true
//                }) {
//                    HStack {
//                        Image(systemName: "camera.viewfinder")
//                            .font(.title2)
//                        Text("Start AR Room Scan")
//                            .fontWeight(.semibold)
//                    }
//                    .frame(minWidth: 250, minHeight: 60)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(15)
//                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
//                }
//                .padding(.bottom, 50)
//            }
//        }
//        .fullScreenCover(isPresented: $viewModel.showARScan) {
//            // This is where we use our SwiftUI wrapper for the AR scanning
//            RoomScannerView(isPresented: $viewModel.showARScan) { corners, floorHeight, ceilingHeight in
//                // Store the room data
//                viewModel.roomCorners = corners
//                viewModel.floorHeight = floorHeight
//                viewModel.ceilingHeight = ceilingHeight
//                
//                // Show the model placement view
//                viewModel.showModelPlacement = true
//            }
//            .edgesIgnoringSafeArea(.all)
//        }
//        .fullScreenCover(isPresented: $viewModel.showModelPlacement) {
//            // Only show this if we have room data
//            if !viewModel.roomCorners.isEmpty {
//                ModelPlacementView(
//                    roomCorners: viewModel.roomCorners,
//                    floorHeight: viewModel.floorHeight,
//                    ceilingHeight: viewModel.ceilingHeight,
//                    isPresented: $viewModel.showModelPlacement
//                )
//                .edgesIgnoringSafeArea(.all)
//            }
//        }
//    }
//}
//
//// Feature row component
//struct FeatureRow: View {
//    let icon: String
//    let text: String
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: icon)
//                .font(.system(size: 22))
//                .foregroundColor(.blue)
//                .frame(width: 30)
//            
//            Text(text)
//                .font(.system(size: 16))
//        }
//    }
//}
//
//// ViewModel to manage AR state
//class ARViewModel: ObservableObject {
//    @Published var showARScan = false
//    @Published var showModelPlacement = false
//    
//    // Room data
//    var roomCorners: [SCNVector3] = []
//    var floorHeight: Float = 0
//    var ceilingHeight: Float = 0
//}
//
//// Preview provider
//struct ARScanView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARScanView()
//    }
//}
