//
//  SmartHomeApp.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

// MARK: - Models
struct Room: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let devices: Int
}

enum ControllerType: String, CaseIterable, Identifiable {
    case pwm2LED = "PWM 2 LED"
    case dataRGB = "1 Data RGB"
    case miniController = "Mini Controller"
    
    var id: String { self.rawValue }
}


