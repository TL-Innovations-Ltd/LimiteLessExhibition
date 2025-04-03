//
//  DeviceInfo.swift
//  Limi
//
//  Created by Mac Mini on 19/03/2025.
//

import SwiftUI
import CoreBluetooth

import Combine

struct DeviceInfo: Equatable {
    let name: String
    let id: String
    var receivedBytes: [UInt8] = []
    
    var isNormalMode: Bool {
        return receivedBytes.first == 91
    }
    
    var isDeveloperMode: Bool {
        return receivedBytes.first == 90
    }
}

class SharedDevice: ObservableObject {
    static let shared = SharedDevice()
    
    @Published var connectedDevice: DeviceInfo?
    @Published var lastReceivedFF02Value: String?
    @Published var lastReceivedBytes: [UInt8] = [] {
        didSet {
            if lastReceivedBytes.count == 2 {
                let mode = lastReceivedBytes[0]
                let flags = lastReceivedBytes[1]
                print("📊 Received Mode: \(mode == 91 ? "Normal" : mode == 90 ? "Developer" : "Unknown")")
                print("📊 Flags Byte: \(String(format: "%08b", flags))")
            }
        }
    }
    
    var isNormalMode: Bool {
        return lastReceivedBytes.first == 91
    }
    
    var isDeveloperMode: Bool {
        return lastReceivedBytes.first == 90
    }
    
    private init() {}
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isBluetoothOn = false
    @Published var storedHubs: [Hub] = []
    @Published var connectedDevices: [UUID: (peripheral: CBPeripheral, characteristic: CBCharacteristic)] = [:]
    
    private var centralManager: CBCentralManager?
    private var discoveredDevices: [(name: String, id: String)] = []
    private var connectedPeripheral: CBPeripheral?
    private var writableCharacteristic: CBCharacteristic?
    @Published var connectedDeviceName: String? = nil
    var storedPeripherals: [CBPeripheral] = []
    
    var peripheral: CBPeripheral?
    static let shared = BluetoothManager()
    
    var targetCharacteristic: CBCharacteristic?
    let ff02Value = SharedDevice.shared.lastReceivedFF02Value ?? ""
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
        
        if !storedPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            storedPeripherals.append(peripheral)
        }
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        
        print("🔍 Discovered: \(name) | ID: \(id)")
        
        if !discoveredDevices.contains(where: { $0.id == id }) {
            discoveredDevices.append((name: name, id: id))
            onDevicesUpdated?(discoveredDevices)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        
        if !storedHubs.contains(where: { $0.id == peripheral.identifier }) {
            let hub = Hub(peripheral: peripheral)
            storedHubs.append(hub)
            print("📌 Stored Hub: \(hub.name)")
        }
        
        connectedPeripheral = peripheral
        SharedDevice.shared.connectedDevice = DeviceInfo(name: peripheral.name ?? "Unknown", id: peripheral.identifier.uuidString)
        DispatchQueue.main.async {
            self.isConnected = true
        }
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        // After services are discovered, this will trigger didDiscoverServices,
        // which will then discover characteristics and automatically send read request
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let disconnectedID = peripheral.identifier.uuidString
        
        print("🔴 Disconnected from \(peripheral.name ?? "Unknown Device")")
        
        targetCharacteristic = nil
        connectedPeripheral = nil
        
        DispatchQueue.main.async {
            SharedDevice.shared.connectedDevice = nil
            self.removeDisconnectedDevice(disconnectedID)
        }
        attemptReconnect()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered Service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Error discovering characteristics: \(error.localizedDescription)")
            // Retry discovery after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
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
                connectedDevices[peripheral.identifier] = (peripheral: peripheral, characteristic: characteristic)
            }
            
            if characteristic.uuid == CBUUID(string: "FF02") {
                print("✅ FF02 characteristic found!")
                if characteristic.properties.contains(.read) {
                    print("📤 Sending read request for FF02")
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Error writing to FF03: \(error.localizedDescription)")
        } else {
            print("✅ Successfully wrote to FF03: \(characteristic.uuid)")
            
            if peripheral.state == .connected {
                print("✅ Peripheral is still connected after writing!")
            } else {
                print("⚠️ Warning: Peripheral might have disconnected after write!")
            }
        }
    }
    
    func sendMessageToDevice(to deviceID: UUID, message: [UInt8]) {
        guard let deviceInfo = connectedDevices[deviceID] else {
            print("⚠️ Device not found!")
            return
        }
        
        let peripheral = deviceInfo.peripheral
        let characteristic = deviceInfo.characteristic
        
        if peripheral.state != .connected {
            print("⚠️ Peripheral is disconnected! Attempting to reconnect...")
            attemptReconnect()
            return
        }
        
        let data = Data(message)
        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse
        
        print("📤 Writing to FF03: \(data)")
        peripheral.writeValue(data, for: characteristic, type: writeType)
    }
    
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
        
        let dataToSend = Data(bytes)
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
    
    func removeDisconnectedDevice(_ deviceID: String) {
        if let uuid = UUID(uuidString: deviceID) {
            DispatchQueue.main.async {
                self.storedHubs.removeAll { $0.id == uuid }
            }
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
    
    func disconnectAllDevices() {
        for hub in storedHubs {
            if let peripheral = hub.peripheral { // Ensure peripheral is not nil
                centralManager?.cancelPeripheralConnection(peripheral)
            }
        }
        storedHubs.removeAll()
        connectedDevices.removeAll()
        connectedPeripheral = nil
        targetCharacteristic = nil
        SharedDevice.shared.connectedDevice = nil
        isConnected = false
        print("🔌 All devices have been disconnected.")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Error reading value: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            print("❌ No data received")
            return
        }
        
        if characteristic.uuid == CBUUID(string: "FF02") {
            let bytes = [UInt8](data)  // Convert Data to byte array
            print("📥 FF02 Raw bytes: \(bytes)")
            
            DispatchQueue.main.async {
                // Store raw bytes directly
                SharedDevice.shared.lastReceivedBytes = bytes
                
                if var device = SharedDevice.shared.connectedDevice {
                    device.receivedBytes = bytes
                    SharedDevice.shared.connectedDevice = device
                }
            }
        }
    }
    func disconnectCurrentDevice() {
        if let peripheral = connectedPeripheral {
            print("🔌 Disconnecting current device: \(peripheral.name ?? "Unknown Device")")
            centralManager?.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
            targetCharacteristic = nil
            SharedDevice.shared.connectedDevice = nil
            isConnected = false
        }
    }
    func writeValue(_ bytes: [UInt8]) {
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
        
        writeDataToFF03(bytes)
    }
    func readValue() {
        guard let peripheral = connectedPeripheral else {
            print("❌ No connected peripheral found!")
            return
        }
        
        if peripheral.state != .connected {
            print("⚠️ Peripheral is disconnected! Attempting to reconnect...")
            attemptReconnect()
            return
        }
        
        // Find FF02 characteristic in all services
        for service in peripheral.services ?? [] {
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == CBUUID(string: "FF02") {
                    print("📥 Sending read request for FF02")
                    peripheral.readValue(for: characteristic)
                    return
                }
            }
        }
        
        print("⚠️ FF02 characteristic not found! Rediscovering services...")
        peripheral.discoverServices(nil)
    }
    
    func stopScanning() {
        centralManager?.stopScan()
        print("🔴 Stopped scanning for peripherals.")
    }
}
