import SwiftUI

struct ContentView: View {
    var body: some View {
        
        ZStack {
            Color.alabaster // Background Color
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Welcome to My App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.charlestonGreen)

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.etonBlue)
                    .frame(width: 300, height: 150)
                    .shadow(radius: 5)
                    .overlay(
                        Text("Beautiful UI Design")
                            .foregroundColor(.charlestonGreen)
                            .font(.title2)
                            .bold()
                    )

                Button(action: {
                    print("Button Pressed")
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.emerald, .etonBlue]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
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
                    removeDevice(hub)
                }) {
                    Text(hub.name)
                }
            }
        }
    }

    func removeDevice(_ hub: Hub) {
        bluetoothManager.removeDisconnectedDevice(hub.id.uuidString)
    }
}

struct MyCustomView_Previews: PreviewProvider {
    static var previews: some View {
        PartHomeView()
    }
}
