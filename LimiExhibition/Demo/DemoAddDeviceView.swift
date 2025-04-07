import SwiftUI

struct DemoAddDeviceView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var isSearching = false
    
    var body: some View {
        VStack {
            if isSearching {
                Text("Searching…")
                    .font(.headline)
                    .padding()
            } else {
                Button(action: {
                    isSearching = true
                    bluetoothManager.addDummyDevice()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isSearching = false
                    }
                }) {
                    Text("Add Device")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}
