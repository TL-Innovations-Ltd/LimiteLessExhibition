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
    let peripheral: CBPeripheral?

    init(peripheral: CBPeripheral?) {
        self.peripheral = peripheral
        self.id = peripheral?.identifier ?? UUID()
        self.name = peripheral?.name ?? "Unknown Hub"
    }
    
    // Convenience initializer for previews/testing.
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.peripheral = nil
    }
    
    static func == (lhs: Hub, rhs: Hub) -> Bool {
        return lhs.id == rhs.id
    }
}


enum ControllerType: String, CaseIterable, Identifiable {
    case pwm2LED = "PWM 2 LED"
    case dataRGB = "1 Data RGB"
    case miniController = "Mini Controller"
    
    var id: String { self.rawValue }
}


