////
////  BLEManager.swift
////  LimiExhibition
////
////  Created by Mac Mini on 03/03/2025.
////
//
//import Foundation
//import CoreBluetooth
//
//import SwiftUI
//
//class BLEManager : NSObject, ObservableObject, CBCentralManagerDelegate,CBPeripheralDelegate {
//    
//    var  myCentral: CBCentralManager!
//    @Published var peripherals = [Peripheral]()
//    @Published var isSwitchedOn: Bool = false
//    @Published var connectedPeripheralUUID :UUID
//    
//        override init() {
//            super.init()
//            super.self.myCentral = CBCentralManager(delegate: self, queue: nil)
//        }
//    
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        isSwitchedOn = central.state == .poweredOn
//        startScanning()
//        }
//    else {
//        stopScanning()
//    }
//    }
//}
