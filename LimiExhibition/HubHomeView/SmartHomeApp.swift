//
//  SmartHomeApp.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

// MARK: - Models
struct Hub: Identifiable {
    let id = UUID()
    let name: String
}

enum ControllerType: String, CaseIterable, Identifiable {
    case pwm2LED = "PWM 2 LED"
    case dataRGB = "1 Data RGB"
    case miniController = "Mini Controller"
    
    var id: String { self.rawValue }
}


