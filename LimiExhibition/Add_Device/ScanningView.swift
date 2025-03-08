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
    @State private var showHubHomeView = false // State for fullscreen navigation
    
    // Bluetooth Manager
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Navigation bar
                HStack {
                                    Button(action: {
                                        onBack()
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                            .padding()
                                            .background(Circle().fill(Color.black.opacity(0.3)))
                                    }
                                    Spacer()
                                }
                                .padding(.top, 50)
                                .padding(.leading, 20)
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
                            .stroke(Color.alabaster.opacity(0.3), lineWidth: 1)
                            .frame(width: 280 - Double(i) * 60, height: 280 - Double(i) * 60)
                    }
                    
                    // Rotating circle
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
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
                            .fill(Color.alabaster.opacity(0.5))
                            .frame(width: 100, height: 100)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(Color.charlestonGreen)
                    }
                }
                .frame(height: 300)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color.etonBlue)
            
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
            
            // Device List Popup
            if showDevicesList {
                Color.black.opacity(0.5) // Background blur effect
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showDevicesList = false
                    }
                
                VStack(spacing: 16) {
                    Text("Discovered Devices")
                        .font(.headline)
                        .foregroundColor(.charlestonGreen)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(discoveredDevices, id: \.id) { device in
                                Text("\(device.name) (\(device.id))")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.emerald.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.charlestonGreen)
                                    .onTapGesture {
                                        bluetoothManager.connectToDevice(deviceId: device.id)
                                        showDevicesList = false // Hide popup after selection
                                        showHubHomeView = true // Trigger fullscreen navigation
                                    }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 600)
                    .background(Color.alabaster.opacity(0.8))
                    .cornerRadius(12)
                    
                    Button(action: {
                        showDevicesList = false
                    }) {
                        Image("closeicon")
                            .renderingMode(.template)
                            .foregroundColor(.emerald)
                            .frame(width: 34, height: 34)
                    }
                }
                .padding()
                .background(Color.alabaster)
                .cornerRadius(16)
                .frame(maxWidth: 350)
                .shadow(radius: 10)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showHubHomeView) {
            //HubContentView()
            HomeView()
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

class SharedDevice {
    static let shared = SharedDevice() // Singleton instance

    var connectedDevice: (name: String, id: String)? // Stores connected device info

    private init() {} // Private initializer prevents external instantiation
}


class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isBluetoothOn = false
    private var centralManager: CBCentralManager?
    private var discoveredDevices: [(name: String, id: String)] = []
    private var connectedPeripheral: CBPeripheral?
    private var writableCharacteristic: CBCharacteristic?
    @Published var connectedDeviceName: String? = nil

        @Published var isConnected: Bool = true


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
        guard isBluetoothOn else {
            print("⚠️ Bluetooth is off. Please enable it to scan.")
            return
        }

        self.onDevicesUpdated = completion
        discoveredDevices.removeAll()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "Unknown Device"
        let id = peripheral.identifier.uuidString

        print("🔍 Discovered: \(name) | ID: \(id)")

        if !discoveredDevices.contains(where: { $0.id == id }) {
            discoveredDevices.append((name: name, id: id))
            onDevicesUpdated?(discoveredDevices)
        }
    }

    func connectToDevice(deviceId: String) {
        guard let uuid = UUID(uuidString: deviceId),
              let peripheral = centralManager?.retrievePeripherals(withIdentifiers: [uuid]).first else {
            print("⚠️ Device not found in retrieved peripherals.")
            return
        }

        print("🔗 Connecting to \(peripheral.name ?? "Unknown Device")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager?.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown Device")")
        DispatchQueue.main.async {
            self.connectedDeviceName = peripheral.name ?? "Unknown Device"
        }
        SharedDevice.shared.connectedDevice = (name: peripheral.name ?? "Unknown Device", id: peripheral.identifier.uuidString)
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔴 Disconnected from \(peripheral.name ?? "Unknown Device")")
        connectedPeripheral = nil  // Clear reference to prevent stale connections
    }

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

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        for characteristic in service.characteristics ?? [] {
            print("📡 Characteristic Found: \(characteristic.uuid) | Properties: \(characteristic.properties)")

            // Check if it's the writable characteristic 0x2A1A
            if characteristic.uuid == CBUUID(string: "2A1A") {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    print("✅ Found Writable Characteristic: \(characteristic.uuid)")
                    writableCharacteristic = characteristic
                    

                }
            }
        }
    }

    
    func connectToDevice() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isConnected = true
        }
    }

    func disconnectDevice() {
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
        
    func sendMessage(_ byteArray: [UInt8]) {
        guard let peripheral = connectedPeripheral,
              let characteristic = writableCharacteristic else {
            print("❌ Peripheral or writable characteristic not found.\(byteArray)")
            return
        }

        // Convert byte array to Data
        let dataToSend = Data(byteArray)

        // Write the byte data to the Bluetooth peripheral
        peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)

        // Debugging: Print byte array in hex format
        let hexString = byteArray.map { String(format: "0x%02X", $0) }.joined(separator: ", ")
        print("📤 Sent to \(characteristic.uuid): \(hexString)")
    }

}


