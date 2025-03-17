//
//  SmartHomeApp.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI
import CoreBluetooth

struct Hub: Identifiable {
    let id: UUID
    let name: String
    let peripheral: CBPeripheral  // Store peripheral reference

    init(peripheral: CBPeripheral) {
        self.id = peripheral.identifier
        self.name = peripheral.name ?? "Unknown Hub"
        self.peripheral = peripheral
    }
}


enum ControllerType: String, CaseIterable, Identifiable {
    case pwm2LED = "PWM 2 LED"
    case dataRGB = "1 Data RGB"
    case miniController = "Mini Controller"
    
    var id: String { self.rawValue }
}


