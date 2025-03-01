import SwiftUI

// MARK: - Device Model
struct Device: Identifiable {
    let id: String
    var name: String
    var deviceID: String
    var isOn: Bool
}

// MARK: - Decodable API Model
struct APIResponse: Codable {
    let success: Bool
    let devices: [DeviceList]
}

struct DeviceList: Codable {
    let _id: String
    let device_name: String
    let device_id: String
    let device_type: String
    let connection_type: String
    let status: String
    let brightness: Int
    let color: String
    let blinking: Bool
}

// MARK: - Bottom Sheet View
struct BottomPopupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var devices: [Device] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(devices) { device in
                    DeviceCardView(device: device) {
                        linkDevice(deviceID: device.deviceID) { success in
                            if success {
                                DispatchQueue.main.async {
                                    devices.removeAll { $0.id == device.id }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Devices")
            .onAppear {
                fetchDevices()
            }
        }
    }
    
    // MARK: - Fetch Devices from API
    func fetchDevices() {
        guard let url = URL(string: "http://localhost:3000/client/devices/alldevices") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    
                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.devices = decodedResponse.devices.map { device in
                            Device(
                                id: device._id,
                                name: "\(device.device_name)",
                                deviceID: device.device_id,
                                isOn: device.status == "on"
                            )
                        }
                    }
                } catch {
                    print("Error decoding JSON:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
    
    // MARK: - Link Device API
    func linkDevice(deviceID: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/client/devices/link_device"),
              let token = AuthManager.shared.getToken() else {
            print("Error: Missing URL or Token")
            return
        }


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["device_id": deviceID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let success = responseJSON?["success"] as? Bool, success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("Error parsing response:", error)
                    completion(false)
                }
            } else if let error = error {
                print("Network error:", error)
                completion(false)
            }
        }.resume()
    }
}

// MARK: - Device Card View
struct DeviceCardView: View {
    var device: Device
    var onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(device.name)
                    .font(.headline)
                Text("ID: \(device.deviceID)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle(isOn: .constant(device.isOn)) { }
                .disabled(true)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        .shadow(radius: 2)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    BottomPopupView()
}
