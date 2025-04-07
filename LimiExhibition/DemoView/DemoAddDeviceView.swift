import SwiftUI

struct DemoAddDeviceView: View {
    @State private var searchingForDevices = true
    @State private var deviceFound = false
    @State private var selectedRoom = "Living Room"
    @State private var deviceName = "LIMI Hub"
    @Environment(\.presentationMode) var presentationMode
    
    let rooms = ["Living Room", "Bedroom", "Kitchen"]
    let onDeviceAdded: (DemoDevice) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                
                if searchingForDevices {
                    searchingView
                } else if deviceFound {
                    deviceFoundView
                }
            }
            .padding()
            .navigationTitle("Add Device")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Simulate searching delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    searchingForDevices = false
                    deviceFound = true
                }
            }
        }
    }
    
    private var searchingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Searching for devices...")
                .font(.headline)
            
            Text("Make sure your device is in pairing mode")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var deviceFoundView: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Image(systemName: "homepod.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .frame(width: 80, height: 80)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                
                VStack(alignment: .leading) {
                    Text("Device Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(deviceName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text("Device Settings")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Device Name")
                    .font(.headline)
                
                TextField("Device Name", text: $deviceName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Room")
                    .font(.headline)
                
                Picker("Select Room", selection: $selectedRoom) {
                    ForEach(rooms, id: \.self) { room in
                        Text(room).tag(room)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            Spacer()
            
            Button(action: {
                let newDevice = DemoDevice(
                    id: UUID().uuidString,
                    name: deviceName,
                    type: .hub,
                    isOn: true
                )
                onDeviceAdded(newDevice)
            }) {
                Text("Add Device")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

