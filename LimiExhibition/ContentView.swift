import SwiftUI



struct ContentView: View {
    @State private var selectedTab = 0
    @State private var toggles: [Bool] = Array(repeating: false, count: 7)
    @StateObject private var sharedDevice = SharedDevice.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Tab - LED Control View
            MainLEDView(toggles: $toggles, sharedDevice: sharedDevice)
                .tabItem {
                    Text("Setting")
                        .bold(true)
                        .font(.title)
                }
                .tag(0)
            
            // Second Tab - Testing View
            TestingView()
                .tabItem {
                    Text("Testing")
                        .bold(true)
                }
                .tag(1)
        }
        .accentColor(.charlestonGreen)
    }
}

// Main LED Control View
struct MainLEDView: View {
    @Binding var toggles: [Bool]
    @ObservedObject var sharedDevice: SharedDevice
    
    var byteRepresentation: String {
        let byte = createByte(from: toggles)
        return String(byte, radix: 2).leftPadding(toLength: 8, withPad: "0")
    }
    
    private func updateTogglesFromByte() {
        if sharedDevice.lastReceivedBytes.count == 2 {
            let flagsByte = sharedDevice.lastReceivedBytes[1]
            for i in 0..<7 {
                toggles[i] = (flagsByte & (1 << (6 - i))) != 0
            }
        }
    }
    
    var body: some View {
        ZStack {
            ElegantGradientBackgroundView()
            
            VStack(spacing: 20) {
                Text("Welcome to My App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.alabaster)
                    .shadow(color:.alabaster, radius: 5)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.charlestonGreen)
                    .opacity(0.3)
                    .frame(width: 300, height: 100)
                    .shadow(radius: 5)
                    .overlay(
                        Text("Byte: \(byteRepresentation)")
                            .foregroundColor(.alabaster)
                            .font(.title2)
                            .bold()
                    )
                
                VStack(spacing: 16) {
                    ForEach(0..<7, id: \.self) { index in
                        LEDToggleButton(index: index, toggles: $toggles)
                    }
                }
                .padding()
                
                SendButton(toggles: toggles, byteRepresentation: byteRepresentation)
            }
            .padding()
        }
        .onAppear {
            updateTogglesFromByte()
        }
        .onChange(of: sharedDevice.lastReceivedBytes) { oldValue, newValue in
            updateTogglesFromByte()
        }
    }
    
    func createByte(from toggles: [Bool]) -> UInt8 {
        guard toggles.count == 7 else {
            fatalError("Exactly 7 toggle states are required.")
        }
        
        var byte: UInt8 = 0
        for (index, isEnabled) in toggles.enumerated() {
            if isEnabled {
                byte |= (1 << (6 - index))
            }
        }
        return byte
    }
}

// Testing View
struct TestingView: View {
    @State private var brightness: Double = 0.5
    @State private var warmCold: Double = 0.5
    @ObservedObject private var bluetoothManager = BluetoothManager.shared

    var body: some View {
        Group {
            if let firstHub = bluetoothManager.storedHubs.first {
                MiniControllerView(
                    hub: firstHub,
                    brightness: $brightness,
                    warmCold: $warmCold
                )
            } else {
                VStack {
                    Text("No devices available")
                        .font(.headline)
                        .foregroundColor(.alabaster)
                    
                    Text("Please connect a device first")
                        .font(.subheadline)
                        .foregroundColor(.alabaster.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ElegantGradientBackgroundView())
            }
        }
    }
}

// Helper Button Views
struct LEDToggleButton: View {
    let index: Int
    @Binding var toggles: [Bool]
    
    var body: some View {
        Button(action: {
            toggles[index].toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack {
                Text("LED \(index + 1)")
                    .foregroundColor(.charlestonGreen)
                    .font(.headline)
                    .frame(width: 60, alignment: .leading)
                
                Toggle("", isOn: $toggles[index])
                    .labelsHidden()
                    .tint(.etonBlue)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: toggles[index])
                    .scaleEffect(toggles[index] ? 1.1 : 1.0)
                    .overlay(
                        Circle()
                            .fill(toggles[index] ? Color.etonBlue.opacity(0.3) : Color.clear)
                            .scaleEffect(toggles[index] ? 1.5 : 0)
                            .animation(.easeOut(duration: 0.3), value: toggles[index])
                    )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 40)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct SendButton: View {
    let toggles: [Bool]
    let byteRepresentation: String
    
    var body: some View {
        Button(action: {
            let firstByte: UInt8 = 91
            let secondByte = createByte(from: toggles)
            let messageBytes: [UInt8] = [firstByte, secondByte]
            
            print("Sending bytes: \(messageBytes)")
            print("Generated Byte: \(byteRepresentation)")
            
            BluetoothManager.shared.writeValue(messageBytes)
            BluetoothManager.shared.readValue()
        }) {
            Text("Save")
                .font(.headline)
                .foregroundColor(.alabaster)
                .padding()
                .frame(width: 200)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.gray, .charlestonGreen]), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(15)
                .shadow(color: .alabaster, radius: 5)
        }
    }
    
    private func createByte(from toggles: [Bool]) -> UInt8 {
        guard toggles.count == 7 else { fatalError("Exactly 7 toggle states are required.") }
        var byte: UInt8 = 0
        for (index, isEnabled) in toggles.enumerated() {
            if isEnabled { byte |= (1 << (6 - index)) }
        }
        return byte
    }
}

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        return String(repeating: character, count: max(0, toLength - self.count)) + self
    }
}




import SwiftUI

struct PartHomeView: View {
    @ObservedObject var bluetoothManager = BluetoothManager.shared  // ✅ Use singleton

    var body: some View {
        VStack {
            Text("Connected Devices")
                .font(.headline)
            
            List(bluetoothManager.storedHubs, id: \.id) { hub in
                Button(action: {
                    
                }) {
                    Text(hub.name)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
        }
    }

}

struct MyCustomView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
