import SwiftUI
import WebKit  // ✅ Ensure WebKit is imported for WebView

struct HomeView: View {
    @State private var isSidebarOpen = false
    @State private var searchText = ""
    @State private var linkedDevices: [DeviceHome] = []
    @State private var isNavigatingToAddDevice = false // ✅ Navigation State
    @ObservedObject var bluetoothManager = BluetoothManager() // ✅ Bluetooth Manager Instance


    var body: some View {
        NavigationStack { // ✅ Wrap inside NavigationStack
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.alabaster.opacity(0.8), Color.etonBlue]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HeaderView(isSidebarOpen: $isSidebarOpen)
                    Button(action: {
                                            bluetoothManager.sendMessage("Hello Device") // Send a test message
                                        }) {
                                            Text("Send Message")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(width: 200)
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        }
                                        .padding(.top, 20)

                    
                    HStack {
                        TextField("Search for a device...", text: $searchText)
                            .frame(width: 300, height: 45)
                            .background(Color.alabaster.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        
                        Button(action: {
                            print("Scanning...")
                        }) {
                            Image("scanBtn")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Show Linked Devices
                    if linkedDevices.isEmpty {
                        Text("No devices linked yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(linkedDevices) { device in
                            HStack {
                                Text(device.name)
                                    .font(.headline)
                                Spacer()
                                Toggle("", isOn: .constant(device.isOn))
                                    .disabled(true)
                            }
                        }
                    }
                    
                    BottomNavigationView()
                }
                
                SidebarView(isSidebarOpen: $isSidebarOpen)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingButton(isNavigating: $isNavigatingToAddDevice)
                    }
                    .fullScreenCover(isPresented: $isNavigatingToAddDevice) {
                        AddDeviceView()
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 120)
                }
            }
            .onAppear {
                fetchLinkedDevices()
            }
        }
    }

    // Fetch Linked Devices
    func fetchLinkedDevices() {
        guard let token = AuthManager.shared.getToken() else {
            print("User not logged in")
            return
        }

        guard let url = URL(string: "https://exhibition-workout-alex-wishlist.trycloudflare.com/client/devices/get_link_devices") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw API Response: \(jsonString)")
                    }

                    let decodedResponse = try JSONDecoder().decode(APIResponseHome.self, from: data)
                    DispatchQueue.main.async {
                        self.linkedDevices = decodedResponse.devices.devices.map { device in
                            DeviceHome(
                                id: UUID().uuidString,
                                name: device.device_name,
                                deviceID: device.device_id,
                                isOn: false
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
}

// MARK: - Device Model
struct DeviceHome: Identifiable, Codable {
    let id: String
    var name: String
    var deviceID: String
    var isOn: Bool
}

// MARK: - Decodable API Model
    struct APIResponseHome: Codable {
        let success: Bool
        let devices: DeviceData
    }

struct DeviceData: Codable {
    let username: String
    let devices: [DeviceListHome]
}

struct DeviceListHome: Codable {
    let device_name: String
    let device_id: String
}

// WebView for Shop
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}



struct HeaderView: View {
    @Binding var isSidebarOpen: Bool

    var body: some View {
        
        HStack {
            Image("logo") // Ensure this image exists in Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 80)
                .padding(10)
                .padding(.bottom,0)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    isSidebarOpen.toggle()
                }
            }) {
                Image(systemName: isSidebarOpen ? "line.horizontal" : "line.horizontal.3")
                    .font(.title)
                    .foregroundColor(.charlestonGreen)
                    .padding(.bottom,0)
            }
            .padding(.horizontal,10)
            .padding(.bottom,0)
        }
        .padding(.horizontal, 0)
        .padding(.top, 100)
        .padding(.bottom, 0)
        .background(
            Color.etonBlue
                .clipShape(
                    RoundedCornerShape(cornerRadius: 30, corners: [.bottomLeft, .bottomRight])
                )
        )
        .opacity(0.9)
        .ignoresSafeArea(edges: .top)// Ensures background extends to the top
        .shadow(radius: 8)
    }
    
}

// Custom Shape for Bottom Rounded Corners
struct RoundedCornerShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}


// Sidebar Menu
struct SidebarView: View {
    @Binding var isSidebarOpen: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isSidebarOpen {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isSidebarOpen = false
                            }
                        }
                }

                HStack {
                    VStack {
                        Button(action: {
                            withAnimation {
                                isSidebarOpen.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.charlestonGreen)
                                Text("Close")
                                    .font(.headline)
                                    .foregroundColor(.charlestonGreen)
                            }
                            .padding()
                        }
                        .padding(.top, 40)

                        Text("Menu 1").padding()
                        Text("Menu 2").padding()
                        Text("Menu 3").padding()

                        Spacer()
                    }
                    .frame(width: geometry.size.width * 0.5)
                    .background(Color.alabaster.opacity(0.8))
                    .offset(x: isSidebarOpen ? 0 : -geometry.size.width * 0.5)
                    .animation(.easeOut, value: isSidebarOpen)

                    Spacer()
                }
            }
        }
    }
}

// Horizontal Scroll View for Favorite Scenes
struct FavoriteScenesView: View {
    let scenes = ["Google", "Fun Leaving", "Relax", "Party"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(scenes, id: \.self) { scene in
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 30))
                        Text(scene)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.alabaster.opacity(0.8))
                    .cornerRadius(10)
                }
            }
        }
    }
}

// Grid for Favorite Accessories
struct FavoriteAccessoriesView: View {
    let accessories = [
        ("Living Room Light", "lightbulb.fill", "80%"),
        ("Front Door", "door.left.hand.open", "Unlocked"),
        ("Thermostat", "thermometer", "70%"),
        ("Hallway Light", "lightbulb", "On")
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(accessories, id: \.0) { accessory in
                VStack {
                    Image(systemName: accessory.1)
                        .font(.system(size: 30))
                    Text(accessory.0)
                        .font(.headline)

                    Text(accessory.2)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.alabaster.opacity(0.8))
                .cornerRadius(10)
            }
        }
    }
}

import SwiftUI

struct BottomNavigationView: View {
    @State private var selectedTab = 0
    @State private var showWebView = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        VStack {
            Spacer()
            HStack {
                TabBarButton(icon: "home", title: "Home", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabBarButton(icon: "magnifying", title: "Search", isSelected: selectedTab == 1) { selectedTab = 1 }
                
                // ✅ Open Camera when clicking the tab
                TabBarButton(icon: "camera", title: "Camera", isSelected: selectedTab == 2) {
                    selectedTab = 2
                    showCamera = true  // Show Camera
                }
                
                TabBarButton(icon: "shop", title: "Shop", isSelected: selectedTab == 3) {
                    selectedTab = 3
                    showWebView = true  // Open WebView
                }
                
                TabBarButton(icon: "person", title: "Profile", isSelected: selectedTab == 4) { selectedTab = 4 }
            }
            .padding()
            .background(Color.charlestonGreen)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        // ✅ Show WebView in Sheet
        .sheet(isPresented: $showWebView) {
            WebViewScreen(showWebView: $showWebView)
        }
    }
}


// Tab Bar Buttons
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .renderingMode(.template) // Enables color change
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isSelected ? Color.charlestonGreen : .gray)
                    .frame(width: 20, height: 20)
                if isSelected {
                    Text(title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.charlestonGreen)
                    
                }
            }
            .padding(.horizontal, isSelected ? 12 : 8)
            .padding(.vertical, 8)
            .background(isSelected ? Color.white : Color.clear)
            .clipShape(Capsule())
        }
    }
}
struct WebViewScreen: View {
    @Binding var showWebView: Bool
    let websiteURL = URL(string: "https://tlhome.co.uk")! // Change to your desired website

    var body: some View {
        NavigationView {
            WebView(url: websiteURL)
                .navigationBarTitle("Shop", displayMode: .inline)
                .navigationBarItems(leading: Button("Close") {
                    showWebView = false
                })
        }
    }
}
// for web View


// Floating Button Component
struct FloatingButton: View {
    @Binding var isNavigating: Bool // ✅ Use a binding to control navigation

    var body: some View {
        Button(action: {
            isNavigating = true // ✅ Trigger navigation
        }) {
            Image(systemName: "plus")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.black)
                .clipShape(Circle())
                .shadow(radius: 10)
        }
        .padding()
    }
}


// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

