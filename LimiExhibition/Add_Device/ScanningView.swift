import SwiftUI
import CoreBluetooth

struct ScanningView: View {
    let progress: Double
    let isAnimating: Bool
    let onBack: () -> Void

    @State private var rotation: Double = 0
    @State private var particlePositions: [(x: Double, y: Double, size: Double, speed: Double)] = []
    @State private var showBluetoothAlert = false
    @State private var showDevicesList = false
    @State private var discoveredDevices: [(name: String, id: String)] = []
    
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
                ForEach(0..<3, id: \ .self) { i in
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
            
            if showDevicesList {
                VStack(spacing: 16) {
                    Text("Discovered Devices")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(discoveredDevices, id: \.id) { device in
                                Text("\(device.name) (\(device.id))")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        bluetoothManager.connectToDevice(deviceId: device.id)
                                    }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 200)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                }
                .padding()
            }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if bluetoothManager.isBluetoothOn {
                showBluetoothAlert = false
                bluetoothManager.startScanning { devices in
                    self.discoveredDevices = devices
                    self.showDevicesList = true
                }
            } else {
                showBluetoothAlert = true
            }
        }
    }
    
    private func openBluetoothSettings() {
        if let url = URL(string: "App-Prefs:root=Bluetooth"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// Bluetooth Manager Class
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isBluetoothOn = false
    private var centralManager: CBCentralManager?
    private var discoveredDevices: [(name: String, id: String)] = []
    private var connectedPeripheral: CBPeripheral?
    var onDevicesUpdated: (([(name: String, id: String)]) -> Void)?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothOn = central.state == .poweredOn
        }
    }

    func startScanning(completion: @escaping ([(name: String, id: String)]) -> Void) {
        self.onDevicesUpdated = completion
        discoveredDevices.removeAll()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Unknown Device"
        let id = peripheral.identifier.uuidString

        if !discoveredDevices.contains(where: { $0.id == id }) {
            discoveredDevices.append((name: name, id: id))
            onDevicesUpdated?(discoveredDevices)
        }
    }

    // 📌 New Function: Connect to a Selected Device
    func connectToDevice(deviceId: String) {
        guard let peripheral = centralManager?.retrievePeripherals(withIdentifiers: [UUID(uuidString: deviceId)!]).first else {
            print("⚠️ Device not found in retrieved peripherals.")
            return
        }

        print("🔗 Connecting to \(peripheral.name ?? "Unknown Device")")
        connectedPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }

    // 📡 Handle Successful Connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown Device")")
        
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil) // Discover services to get more details

        // 🔹 Try to read the device name
        if let name = peripheral.name {
            print("📌 Updated Device Name: \(name)")
        }
    }


    // ❌ Handle Failed Connection
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")")
    }

    // 🔴 Handle Disconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔴 Disconnected from \(peripheral.name ?? "Unknown Device")")
    }

    // 🔍 Discover Services after Connection
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ Error discovering services: \(error.localizedDescription)")
            return
        }

        for service in peripheral.services ?? [] {
            print("🔧 Service Found: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // 📡 Discover Characteristics within a Service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        for characteristic in service.characteristics ?? [] {
            print("📡 Characteristic Found: \(characteristic.uuid) | Properties: \(characteristic.properties)")
        }
    }
}

