//import SwiftUI
//import CoreBluetooth
//
//struct NearbyDevicesView: View {
//    @State private var progress: Double = 0.0
//    @State private var showBluetoothAlert = false
//    @StateObject private var bluetoothManager = BluetoothManager()
//    @State private var isAnimating = false
//    @State private var showPopup = false
//    @State private var popupMessage: String?
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                // Back Button
//               
//                
//                Spacer()
//                
//                // Title
//                Text("Looking for\nnearby devices")
//                    .font(.title2)
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.bottom, 40)
//                
//                // Animation + Progress Circle
//                ZStack {
//                    ForEach(0..<4, id: \.self) { index in
//                        Circle()
//                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
//                            .frame(width: 200, height: 200)
//                            .scaleEffect(isAnimating ? 1.8 : 0.8)
//                            .opacity(isAnimating ? 0 : 1)
//                            .animation(
//                                Animation.easeInOut(duration: 1.5)
//                                    .repeatForever()
//                                    .delay(Double(index) * 0.6),
//                                value: isAnimating
//                            )
//                    }
//                    
//                    Circle()
//                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
//                        .frame(width: 180, height: 180)
//                    
//                    Circle()
//                        .trim(from: 0, to: progress / 100)
//                        .stroke(Color.white, lineWidth: 5)
//                        .rotationEffect(.degrees(-90))
//                        .frame(width: 150, height: 150)
//                        .animation(.easeInOut(duration: 3.5), value: progress)
//                    
//                    Text("\(Int(progress))%")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom, 40)
//                .onAppear {
//                    isAnimating = true
//                    startTimer()
//                }
//                
//                Spacer()
//
//                // Help Text
//                VStack(spacing: 10) {
//                    Text("Have a problem finding a device?")
//                        .foregroundColor(.white.opacity(0.7))
//                        .font(.subheadline)
//
//                    // Scan QR Code Button
//                    Button(action: {
//                        // Scan QR Code action
//                    }) {
//                        Text("Scan QR Code")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                    }
//                }
//
//                Divider()
//                    .background(Color.white.opacity(0.3))
//                    .padding(.horizontal, 40)
//                    .padding(.vertical, 10)
//
//                // Enter Manually Button
//                Button(action: {
//                    // Enter manually action
//                }) {
//                    HStack {
//                        Image(systemName: "hand.tap")
//                        Text("Enter manually")
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue.opacity(0.8))
//                    .cornerRadius(10)
//                }
//                .padding(.horizontal, 40)
//
//                Spacer()
//            }
//        }
//        .onAppear {
//            bluetoothManager.checkBluetoothStatus()
//        }
//        .onChange(of: bluetoothManager.isBluetoothEnabled) { oldValue, newValue in
//            if !newValue {
//                showBluetoothAlert = true
//            }
//        }
//        .alert(isPresented: $showBluetoothAlert) {
//            Alert(
//                title: Text("Bluetooth Required"),
//                message: Text("Please enable Bluetooth to scan for nearby devices."),
//                primaryButton: .default(Text("Settings"), action: {
//                    openBluetoothSettings()
//                }),
//                secondaryButton: .cancel()
//            )
//        }
//        .sheet(isPresented: $showPopup) {
//                    BottomPopupView()
//                }
//    }
//
//    private func startTimer() {
//        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
//            DispatchQueue.main.async {
//                withAnimation(.easeInOut(duration: 3.5)) {
//                    for i in 1...100 {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
//                            progress = Double(i)
//                            if i == 100 {
//                                showPopup = true  // Show popup when progress reaches 100
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    // Open Bluetooth Settings
//    private func openBluetoothSettings() {
//        if let url = URL(string: UIApplication.openSettingsURLString) {
//            UIApplication.shared.open(url)
//        }
//        
//    }
//}
//
//// MARK: - Bluetooth Manager
//class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
//    private var centralManager: CBCentralManager?
//    @Published var isBluetoothEnabled: Bool = true
//
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//
//    func checkBluetoothStatus() {
//        if let centralManager = centralManager {
//            centralManagerDidUpdateState(centralManager)
//        }
//    }
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        DispatchQueue.main.async {
//            self.isBluetoothEnabled = (central.state == .poweredOn)
//        }
//    }
//}
//
//// Preview
//struct NearbyDevicesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NearbyDevicesView()
//    }
//}
