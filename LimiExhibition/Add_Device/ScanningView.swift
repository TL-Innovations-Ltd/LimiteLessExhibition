import SwiftUI
import CoreBluetooth

struct ScanningView: View {
    let progress: Double
    let isAnimating: Bool
    let onBack: () -> Void

    @State private var rotation: Double = 0
    @State private var particlePositions: [(x: Double, y: Double, size: Double, speed: Double)] = []
    @State private var showBluetoothAlert = false
    
    // Bluetooth Manager
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some View {
        VStack(spacing: 24) {
            // Navigation bar
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.top, 8)
            
            Spacer()
            
            // Title
            Text("Looking for\nnearby devices")
                .font(.largeTitle)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            
            // Scanning animation
            ZStack {
                // Outer circles
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 280 - Double(i) * 60, height: 280 - Double(i) * 60)
                }
                
                // Rotating circle
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: 280, height: 280)
                    .rotationEffect(Angle(degrees: rotation))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                        
                        // Initialize particles
                        particlePositions = (0..<15).map { _ in
                            let distance = Double.random(in: 20...140)
                            let angle = Double.random(in: 0...360)
                            let x = cos(angle * .pi / 180) * distance
                            let y = sin(angle * .pi / 180) * distance
                            let size = Double.random(in: 2...6)
                            let speed = Double.random(in: 0.5...2.0)
                            return (x: x, y: y, size: size, speed: speed)
                        }
                    }
                
                // Particles
                ForEach(0..<particlePositions.count, id: \.self) { i in
                    let position = particlePositions[i]
                    Circle()
                        .fill(particleShape(for: i))
                        .frame(width: position.size, height: position.size)
                        .offset(x: position.x, y: position.y)
                        .animation(
                            Animation.easeInOut(duration: position.speed)
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: isAnimating
                        )
                }
                
                // Progress indicator
                ZStack {
                    Circle()
                        .fill(Color(white: 0.1))
                        .frame(width: 100, height: 100)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 300)
            
            Spacer()
            
            // Bottom options
            VStack(spacing: 16) {
                Text("Have a problem finding a device?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {}) {
                    Text("Scan QR Code")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Text("or")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "hand.tap")
                        Text("Enter manually")
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color(white: 0.15))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color.black)
        .onAppear {
            checkBluetoothStatus()
        }
        .alert(isPresented: $showBluetoothAlert) {
            Alert(
                title: Text("Bluetooth is turned off"),
                message: Text("Turn on Bluetooth to scan for nearby devices."),
                primaryButton: .default(Text("Settings"), action: openBluetoothSettings),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func checkBluetoothStatus() {
        if !bluetoothManager.isBluetoothOn {
            showBluetoothAlert = true
        }
    }
    
    private func openBluetoothSettings() {
        if let url = URL(string: "App-Prefs:root=Bluetooth"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func particleShape(for index: Int) -> some ShapeStyle {
        if index % 3 == 0 {
            return Color.white.opacity(0.7)
        } else if index % 3 == 1 {
            return Color.gray.opacity(0.5)
        } else {
            return Color.white.opacity(0.3)
        }
    }
}

// Bluetooth Manager Class
class BluetoothManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    @Published var isBluetoothOn = false
    private var peripheralManager: CBPeripheralManager?

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        DispatchQueue.main.async {
            self.isBluetoothOn = peripheral.state == .poweredOn
        }
    }
}
