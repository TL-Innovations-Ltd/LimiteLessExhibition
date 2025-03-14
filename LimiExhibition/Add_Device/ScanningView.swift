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
    @State private var currentProgress: Int = 1

    // Bluetooth Manager
    @StateObject private var bluetoothManager = BluetoothManager.shared

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
                        Text("\(Int(currentProgress))%")
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
                
                // Start a timer that updates progress step-by-step
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if currentProgress < 100 {
                        currentProgress += 1
                    } else {
                        timer.invalidate() // Stop the timer when it reaches 100
                    }
                }
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
                Color.charlestonGreen.opacity(0.5) // Background blur effect
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

import Combine

struct DeviceInfo: Equatable {
    let name: String
    let id: String
}

class SharedDevice: ObservableObject {
    static let shared = SharedDevice()

    @Published var connectedDevice: DeviceInfo? // ✅ Now using a struct

    private init() {}
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]

    @Published var isBluetoothOn = false
    private var centralManager: CBCentralManager?
    private var discoveredDevices: [(name: String, id: String)] = []
    private var connectedPeripheral: CBPeripheral?
    private var writableCharacteristic: CBCharacteristic?
    @Published var connectedDeviceName: String? = nil
    var storedPeripherals: [CBPeripheral] = [] // Add this in BluetoothManager
    
    var peripheral: CBPeripheral?  // Ensure this is correctly defined
    
    static let shared = BluetoothManager() // Singleton instance
    
    var targetCharacteristic: CBCharacteristic?
    
    @Published var isConnected: Bool = false

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

        // Store the peripheral to maintain a strong reference
        if !storedPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            storedPeripherals.append(peripheral)
        }

        self.peripheral = peripheral  // Assign a valid peripheral
        self.peripheral?.delegate = self  // Set delegate to receive updates

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
        print("✅ Connected to \(peripheral.name ?? "Unknown")")

        // Store connected peripheral
        connectedPeripheral = peripheral
        SharedDevice.shared.connectedDevice = DeviceInfo(name: peripheral.name ?? "Unknown", id: peripheral.identifier.uuidString)
        DispatchQueue.main.async {
            self.isConnected = true
        }

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔴 Disconnected from \(peripheral.name ?? "Unknown Device")")

        targetCharacteristic = nil // Reset characteristic
        connectedPeripheral = nil  // Clear connected peripheral
        DispatchQueue.main.async {
            SharedDevice.shared.connectedDevice = nil // ✅ Update state
        }

        // Try to reconnect immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("♻️ Attempting to reconnect to \(peripheral.identifier.uuidString)...")
            self.centralManager?.connect(peripheral, options: nil)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered Service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // Step 5: Discover Characteristics (Find FF03)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            print("❌ No characteristics found!")
            return
        }

        for characteristic in characteristics {
            print("🔎 Discovered Characteristic: \(characteristic.uuid)")

            if characteristic.uuid == CBUUID(string: "FF03") {
                print("✅ FF03 characteristic found!")
                self.targetCharacteristic = characteristic

                if characteristic.properties.contains(.notify) {
                    print("🔔 Enabling notifications for FF03")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Error writing to FF03: \(error.localizedDescription)")
        } else {
            print("✅ Successfully wrote to FF03: \(characteristic.uuid)")

            // Verify if the peripheral is still connected
            if peripheral.state == .connected {
                print("✅ Peripheral is still connected after writing!")
            } else {
                print("⚠️ Warning: Peripheral might have disconnected after write!")
            }
        }
    }
    // Function to write data to the FF03 characteristic
    func writeDataToFF03(_ bytes: [UInt8]) {
        guard let peripheral = connectedPeripheral else {
            print("❌ No connected peripheral found! Reconnecting...")
            attemptReconnect()
            return
        }

        if peripheral.state != .connected {
            print("⚠️ Peripheral is disconnected! Attempting to reconnect...")
            attemptReconnect()
            return
        }

        guard let characteristic = targetCharacteristic else {
            print("⚠️ FF03 characteristic is missing! Rediscovering...")
            peripheral.discoverServices(nil)
            return
        }

        let dataToSend = Data(bytes) // Convert byte array to Data
        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse

        print("📤 Writing to FF03: \(dataToSend)")
        peripheral.writeValue(dataToSend, for: characteristic, type: writeType)
    }

    func startKeepAlive() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.connectedPeripheral?.state == .connected {
                print("🔄 Sending keep-alive ping...")
                self.writeDataToFF03([0x01, 0x02, 0x03])
            } else {
                print("⚠️ Cannot send keep-alive, peripheral disconnected!")
            }
        }
    }

    func attemptReconnect() {
        if let savedDevice = SharedDevice.shared.connectedDevice {
            let uuid = UUID(uuidString: savedDevice.id)!
            let peripherals = centralManager?.retrievePeripherals(withIdentifiers: [uuid]) ?? []
            
            if let peripheral = peripherals.first {
                print("♻️ Attempting to reconnect to \(savedDevice.name)...")
                connectedPeripheral = peripheral
                centralManager?.connect(peripheral, options: nil)
                return
            }
        }

        print("⚠️ No known peripheral to reconnect. Start scanning again.")
        startScanning { _ in }
    }
}
