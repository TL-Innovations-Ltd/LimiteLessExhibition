import SwiftUI

enum DemoDeviceType {
    case light
    case pendantLight
    case rgbLight
    case tv
    case appliance
    case hub
}

struct DemoRoom: Identifiable {
    let id = UUID()
    let name: String
    var devices: [DemoDevice]
}

struct DemoDevice: Identifiable {
    let id: String
    let name: String
    let type: DemoDeviceType
    var isOn: Bool
    var brightness: Double = 100
    var color: Color = .red
    var colorTemperature: Double = 0.5 // 0 = warm, 1 = cool
    var isAIControlled: Bool = false
    var isRainbowMode: Bool = false
    
    var iconName: String {
        switch type {
        case .light, .pendantLight, .rgbLight:
            return "lightbulb.fill"
        case .tv:
            return "tv.fill"
        case .appliance:
            return "switch.2"
        case .hub:
            return "homepod.fill"
        }
    }
}

