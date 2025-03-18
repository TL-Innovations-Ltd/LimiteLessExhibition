import SwiftUI
import WebKit

struct HomeView: View {
    // MARK: - Properties
    @State private var isSidebarOpen = false
    @State private var searchText = ""
    @State private var linkedDevices: [DeviceHome] = []
    @State private var isNavigatingToAddDevice = false
    
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    @ObservedObject var sharedDevice = SharedDevice.shared

    // Animation states
    @State private var isLoaded = false
    @State private var searchFieldFocused = false
    @State private var headerOffset: CGFloat = -100
    @State private var shimmerAnimation = false // For shimmer effect
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Enhanced Background with Animated Gradient
                ZStack {
                    // Base gradient
                    LinearGradient(gradient: Gradient(colors: [Color.charlestonGreen.opacity(0.8), Color.alabaster.opacity(0.9)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                    
                    // Animated overlay gradient for dynamic effect
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: UIScreen.main.bounds.width * 1.3
                    )
                    .scaleEffect(shimmerAnimation ? 1.2 : 0.8)
                    .opacity(shimmerAnimation ? 0.7 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 4)
                            .repeatForever(autoreverses: true),
                        value: shimmerAnimation
                    )
                    .onAppear {
                        shimmerAnimation = true
                    }
                    
                    // Subtle pattern overlay
                    ZStack {
                        ForEach(0..<5) { i in
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: CGFloat.random(in: 100...200))
                                .position(
                                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                                )
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // MARK: - Main Content
                VStack(spacing: 0) { // Removed spacing between VStack elements
                    // MARK: - Header with Slide-in Animation
                    HeaderView(isSidebarOpen: $isSidebarOpen)
                        .offset(y: headerOffset)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: headerOffset)
                        .ignoresSafeArea()
                    
                    // MARK: - Search Bar with Focus Animation - SPACING DECREASED
                    HStack {
                        TextField("Search for a device...", text: $searchText)
                            .padding(.horizontal, 15)
                            .frame(height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: Color.black.opacity(0.1), radius: searchFieldFocused ? 8 : 3, x: 0, y: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.etonBlue.opacity(searchFieldFocused ? 0.5 : 0), lineWidth: 2)
                                    )
                            )
                            .onTapGesture {
                                withAnimation {
                                    searchFieldFocused = true
                                }
                            }
                            .onSubmit {
                                searchFieldFocused = false
                            }
                        
                        // MARK: - Enhanced Scan Button with Pulse Animation
                        Button(action: {
                            print("Scanning...")
                            // Animation: Trigger pulse effect when scanning
                            withAnimation(.spring()) {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            }
                        }) {
                            ZStack {
                                // Animated ring
                                Circle()
                                    .stroke(Color.etonBlue.opacity(0.3), lineWidth: 2)
                                    .frame(width: 50, height: 50)
                                    .scaleEffect(isLoaded ? 1.2 : 0.8)
                                    .opacity(isLoaded ? 0.0 : 0.8)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: false),
                                        value: isLoaded
                                    )
                                
                                // Button background
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.charlestonGreen, Color.charlestonGreen.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 45, height: 45)
                                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                                
                                // Icon
                                Image("scanBtn")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.alabaster)
                                    .frame(width: 22, height: 22)
                                    .scaleEffect(isLoaded ? 1.0 : 0.95)
                                    
                            }
                        }
                    }
                    .padding(.horizontal, 5) // Kept at 5 as requested
                    .padding(.top, 0) // REMOVED TOP PADDING to decrease spacing
                    .offset(y: -5) // Added negative offset to move search bar up closer to header
                    
                    // MARK: - Enhanced Devices Section with Staggered Animation
                    VStack(alignment: .leading) {
                        HStack {
                            Text("My Hubs")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.charlestonGreen)
                        }
                        .padding(.horizontal, 5) // REDUCED TO 5
                        .padding(.top, 15)
                        .opacity(isLoaded ? 1 : 0)
                        .animation(.easeIn.delay(0.3), value: isLoaded)
                        
                        if bluetoothManager.storedHubs.isEmpty {
                                        // ❌ No hubs found → Show Empty State
                                        VStack(spacing: 20) {
                                            ZStack {
                                                ForEach(0..<3, id: \.self) { i in
                                                    Circle()
                                                        .stroke(Color.etonBlue.opacity(0.1), lineWidth: 2)
                                                        .frame(width: 120 + CGFloat(i * 30), height: 120 + CGFloat(i * 30))
                                                        .scaleEffect(isLoaded ? 1.0 : 0.8)
                                                        .opacity(isLoaded ? 1 : 0)
                                                        .animation(.easeInOut(duration: 1.0).delay(0.3 + Double(i) * 0.1), value: isLoaded)
                                                }
                                                Image(systemName: "house.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.etonBlue)
                                                    .opacity(isLoaded ? 1 : 0)
                                                    .scaleEffect(isLoaded ? 1 : 0.5)
                                                    .rotationEffect(isLoaded ? .degrees(0) : .degrees(-30))
                                                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: isLoaded)
                                            }
                                            .frame(height: 150)
                                            .padding(.top, 20)

                                            VStack(spacing: 10) {
                                                Text("No devices linked yet")
                                                    .font(.headline)
                                                    .foregroundColor(.charlestonGreen)
                                                    .opacity(isLoaded ? 1 : 0)
                                                    .animation(.easeIn.delay(0.6), value: isLoaded)

                                                Text("Tap + to add your first device")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray.opacity(0.8))
                                                    .opacity(isLoaded ? 1 : 0)
                                                    .animation(.easeIn.delay(0.8), value: isLoaded)
                                                    .padding(.bottom, 10)

                                                Button(action: {
                                                    isNavigatingToAddDevice = true
                                                }) {
                                                    HStack {
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.system(size: 16))
                                                        Text("Add Device")
                                                            .fontWeight(.medium)
                                                    }
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 10)
                                                    .padding(.horizontal, 20)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(Color.etonBlue)
                                                    )
                                                    .shadow(color: Color.etonBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                                                }
                                                .opacity(isLoaded ? 1 : 0)
                                                .animation(.easeIn.delay(1.0), value: isLoaded)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                        } else {
                            // ✅ Hubs Available → Show Hub List
                            ScrollView(showsIndicators: false) {
                                ForEach(Array(bluetoothManager.storedHubs.enumerated()), id: \.element.id) { index, hub in
                                    NavigationLink(destination: HomeDetailView(hub: hub)) {
                                        HubCardView(hub: hub, bluetoothManager: bluetoothManager)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 8)
                                            .offset(x: isLoaded ? 0 : 300)
                                            .opacity(isLoaded ? 1 : 0)
                                            .animation(
                                                .spring(response: 0.6, dampingFraction: 0.7)
                                                .delay(Double(index) * 0.1 + 0.3),
                                                value: isLoaded
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .onAppear {
                                isLoaded = true
                            }
                        }
                    }
                    .onAppear {
                        isLoaded = true
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    
                    Spacer()
                }
                
                // MARK: - Enhanced Sidebar with Improved Animation
                EnhancedSidebarView(isSidebarOpen: $isSidebarOpen)
                
                // MARK: - Enhanced Floating Button with Bounce Animation
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        EnhancedFloatingButton(isNavigating: $isNavigatingToAddDevice)
                            // Animation: Bounce in from bottom
                            .offset(y: isLoaded ? 0 : 100)
                            .opacity(isLoaded ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: isLoaded)
                    }
                    .fullScreenCover(isPresented: $isNavigatingToAddDevice) {
                        AddDeviceView()
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 120)
                }
            }
            
            .onAppear {
                // Trigger animations when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        headerOffset = 0
                        isLoaded = true
                    }
                }
                fetchLinkedDevices()
            }
            // MARK: - Enhanced Bottom Navigation
            .overlay(
                EnhancedBottomNavigationView()
                    .offset(y: isLoaded ? 0 : 100)
                    // Animation: Slide up from bottom
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: isLoaded),
                alignment: .bottom
            )
        }
    }

    // MARK: - API Functions
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

// MARK: - Device Models
struct DeviceHome: Identifiable, Codable {
    let id: String
    var name: String
    var deviceID: String
    var isOn: Bool
}

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

// MARK: - WebView Component
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

struct HubCardView: View {
    let hub: Hub
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var pulseAnimation = false
    @State private var isExpanded = false
    @State private var showAlert = false
    @State private var isAnimating = true
    @State private var buttonOpacity = 0.2
    @State private var selectedMode: String? = nil
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var brightness: Double = 0.5
    @State private var warmCold: Double = 0.5
    @State private var navigateToMiniController = false

    var destinationView: some View {
        switch selectedMode {
        case "PWM":
            return AnyView(PWM2LEDView(hub: hub))
        case "RGB":
            return AnyView(DataRGBView())
        case "MiniController":
            return AnyView(MiniControllerView(hub: hub, brightness: $brightness, warmCold: $warmCold)) // Pass the hub to MiniControllerView
        default:
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        ZStack {
            if !hasModeButton {
                NavigationLink(destination: MiniControllerView(hub: hub, brightness: $brightness, warmCold: $warmCold), isActive: $navigateToMiniController) {
                    EmptyView()
                }
                .opacity(0)
            }

            VStack(alignment: .leading) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.etonBlue.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .scaleEffect(pulseAnimation ? 1.2 : 0.9)
                            .opacity(pulseAnimation ? 0.6 : 0.2)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.etonBlue.opacity(0.8), Color.etonBlue.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        Image(systemName: "house.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .onAppear {
                        pulseAnimation = true
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bluetoothManager.connectedDeviceName ?? hub.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.charlestonGreen)
                        
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .opacity(pulseAnimation ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true),
                                    value: pulseAnimation
                                )
                            Text("Connected")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    Spacer()
                    
                    if hasModeButton {
                        Button(action: {
                            showAlert = true
                        }) {
                            Text(selectedMode == nil ? "Mode" : "Mode: \(selectedMode!)")
                                .font(.title)
                                .foregroundColor(.black)
                                .opacity(buttonOpacity)
                                .animation(isAnimating ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .none, value: buttonOpacity)
                        }
                        .disabled(selectedMode != nil)
                        .onAppear {
                            startAnimation()
                        }
                        .confirmationDialog("Please Select Your Mode", isPresented: $showAlert, titleVisibility: .visible) {
                            Button("PWM") { selectMode("PWM") }
                            Button("RGB") { selectMode("RGB") }
                            Button("MiniController") { selectMode("MiniController") }
                            Button("Cancel", role: .cancel) { }
                        }
                    }

                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.emerald.opacity(0.8))
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                }
            }
            .padding()
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.white, .alabaster.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .onTapGesture {
                let impactMed = UIImpactFeedbackGenerator(style: .light)
                impactMed.impactOccurred()

                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
                
                if !hasModeButton {
                    navigateToMiniController = true
                }
                
                sendMessage(hub: hub)
            }
            .onHover { hovering in
                isHovered = hovering
            }

            NavigationLink(destination: destinationView, isActive: Binding(
                get: { selectedMode != nil },
                set: { if !$0 { selectedMode = nil } }
            )) {
                EmptyView()
            }
            .opacity(0)
            .onTapGesture {
                sendMessage(hub: hub)
            }
        }
    }

    private func sendMessage(hub: Hub) {
        if let device = bluetoothManager.connectedDevices[hub.id] {
            let message = "Hello, \(hub.name)!"
            let data = Array(message.utf8)
            bluetoothManager.sendMessageToDevice(to: hub.id, message: data)
        } else {
            print("Device not connected")
        }
    }
    
    private func startAnimation() {
        DispatchQueue.main.async {
            buttonOpacity = 1.0
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                buttonOpacity = 0.5
            }
        }
    }
    
    private func selectMode(_ mode: String) {
        selectedMode = mode
        isAnimating = false
        buttonOpacity = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                buttonOpacity = 0.8
            }
        }
    }

    private var hasModeButton: Bool {
        return (bluetoothManager.connectedDeviceName ?? hub.name) != "LIMI-CONTROLLER"
    }
}

// MARK: - Enhanced Header View with Animation
struct HeaderView: View {
    @Binding var isSidebarOpen: Bool
    @State private var logoScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0

    var body: some View {
        HStack {
            // Enhanced logo with glow effect
            ZStack {
                // Glow effect
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 80)
                    .blur(radius: 5)
                    .opacity(glowOpacity)
                
                // Actual logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 80)
                    .scaleEffect(logoScale)
            }
            .padding(5) // REDUCED TO 5
            .onAppear {
                // Animation: Subtle logo pulse with glow
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    logoScale = 1.05
                    glowOpacity = 0.3
                }
            }
            
            Spacer()
            
            // Enhanced menu button with rotation and glow
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isSidebarOpen.toggle()
                    
                    // Haptic feedback when toggling menu
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                }
            }) {
                ZStack {
                    // Button glow
                    Circle()
                        .fill(Color.etonBlue.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .blur(radius: 5)
                        .opacity(isSidebarOpen ? 0.7 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isSidebarOpen)
                    
                    // Button background
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.alabaster.opacity(0.9)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 45, height: 45)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    
                    // Icon
                    Image(systemName: isSidebarOpen ? "xmark" : "line.horizontal.3")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.charlestonGreen)
                }
                // Animation: Rotate when toggling
                .rotationEffect(.degrees(isSidebarOpen ? 90 : 0))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSidebarOpen)
            }
            .padding(.horizontal, 15)
        }
        .padding(.top, 50)
        .padding(.bottom, 0) // REDUCED TO 0 to decrease spacing
        .background(
            // Enhanced header background with depth and animation
            ZStack {
                // Base color
                Color.charlestonGreen.opacity(0.8)
                
                // Animated gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.1), Color.clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(glowOpacity * 2)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowOpacity)
                
                // Decorative elements
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .offset(x: -120, y: 20)
                    .scaleEffect(logoScale)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: logoScale)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .offset(x: 140, y: -30)
                    .scaleEffect(2 - logoScale)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: logoScale)
            }
            .clipShape(
                RoundedCornerShape(cornerRadius: 5, corners: [.bottomLeft, .bottomRight])
            )
        )
        .shadow(
            color: Color.black.opacity(0.65),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}

// MARK: - Custom Shape for Rounded Corners
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

// MARK: - Enhanced Sidebar with Improved Animation
struct EnhancedSidebarView: View {
    @Binding var isSidebarOpen: Bool
    @State private var menuItems = [
        ("house.fill", "Home"),
        ("gear", "Settings"),
        ("person.fill", "Profile"),
        ("questionmark.circle", "Help"),
        ("info.circle", "About")
    ]
    @State private var selectedItem = "Home"
    @State private var animateBackground = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced dimmed background with blur
                if isSidebarOpen {
                    Color.black.opacity(0.3)
                        .blur(radius: 0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isSidebarOpen = false
                            }
                        }
                        // Animation: Fade in/out background
                        .animation(.easeOut(duration: 0.2), value: isSidebarOpen)
                }

                HStack(spacing: 0) {
                    // Enhanced sidebar content
                    ZStack {
                        // Animated background
                        LinearGradient(
                            gradient: Gradient(colors: [Color.alabaster, Color.white.opacity(0.95)]),
                            startPoint: animateBackground ? .topLeading : .bottomTrailing,
                            endPoint: animateBackground ? .bottomTrailing : .topLeading
                        )
                        .onAppear {
                            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                                animateBackground.toggle()
                            }
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 0) {
                            // Enhanced user profile section
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            isSidebarOpen.toggle()
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.black.opacity(0.05))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "xmark")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.charlestonGreen)
                                        }
                                    }
                                    .padding(.trailing, 20)
                                    .padding(.top, 20)
                                }
                                
                                // Enhanced user avatar and info
                                HStack(spacing: 15) {
                                    // Avatar with gradient and animation
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.etonBlue, Color.etonBlue.opacity(0.7)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                            .shadow(color: Color.etonBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                                        
                                        // Animated ring
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                            .frame(width: 70, height: 70)
                                            .scaleEffect(animateBackground ? 1.1 : 0.9)
                                            .opacity(animateBackground ? 0.7 : 0.3)
                                            .animation(
                                                Animation.easeInOut(duration: 2)
                                                    .repeatForever(autoreverses: true),
                                                value: animateBackground
                                            )
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Welcome")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Text("User")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.charlestonGreen)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            .padding(.bottom, 30)
                            
                            // Enhanced menu items with staggered animation
                            ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                                Button(action: {
                                    withAnimation {
                                        selectedItem = item.1
                                        
                                        // Haptic feedback
                                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                                        impactMed.impactOccurred()
                                    }
                                }) {
                                    HStack(spacing: 15) {
                                        // Icon with background for selected item
                                        ZStack {
                                            Circle()
                                                .fill(selectedItem == item.1 ? Color.etonBlue.opacity(0.2) : Color.clear)
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: item.0)
                                                .font(.system(size: 18))
                                                .foregroundColor(selectedItem == item.1 ? Color.etonBlue : .charlestonGreen.opacity(0.7))
                                        }
                                        
                                        Text(item.1)
                                            .font(.headline)
                                            .foregroundColor(selectedItem == item.1 ? Color.etonBlue : .charlestonGreen.opacity(0.7))
                                        
                                        Spacer()
                                        
                                        if selectedItem == item.1 {
                                            Circle()
                                                .fill(Color.etonBlue)
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    // Enhanced animation: Highlight on selection
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedItem == item.1 ? Color.etonBlue.opacity(0.1) : Color.clear)
                                            .padding(.horizontal, 10)
                                    )
                                }
                                // Enhanced animation: Staggered slide-in from left with spring
                                .offset(x: isSidebarOpen ? 0 : -50)
                                .opacity(isSidebarOpen ? 1 : 0)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(isSidebarOpen ? Double(index) * 0.05 : 0),
                                    value: isSidebarOpen
                                )
                            }
                            
                            Spacer()
                            
                            // Enhanced logout button with animation
                            Button(action: {
                                // Logout action
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.1))
                                            .frame(width: 36, height: 36)
                                        
                                        Image(systemName: "arrow.left.square.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    
                                    Text("Logout")
                                        .font(.headline)
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 30)
                            // Enhanced animation: Fade in/out with scale
                            .opacity(isSidebarOpen ? 1 : 0)
                            .scaleEffect(isSidebarOpen ? 1 : 0.9)
                            .animation(.easeIn.delay(isSidebarOpen ? 0.3 : 0), value: isSidebarOpen)
                        }
                    }
                    .frame(width: geometry.size.width * 0.7)
                    // Enhanced animation: Slide in/out with spring physics and shadow
                    .offset(x: isSidebarOpen ? 0 : -geometry.size.width * 0.7)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSidebarOpen)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 5, y: 0)

                    Spacer()
                }
            }
        }
    }
}



// MARK: - Enhanced Bottom Navigation
struct EnhancedBottomNavigationView: View {
    @State private var selectedTab = 0
    @State private var showWebView = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var tabBarOffset: CGFloat = 0
    @State private var previousScrollOffset: CGFloat = 0
    @State private var animateGlow = false
    
    var body: some View {
        VStack {
            Spacer()
            // Enhanced bottom navigation bar with glass effect
            ZStack {
                // Animated glow effect
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.etonBlue.opacity(0.2))
                    .blur(radius: 10)
                    .frame(height: 70)
                    .padding(.horizontal, 10)
                    .opacity(animateGlow ? 0.5 : 0.2)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: animateGlow
                    )
                    .onAppear {
                        animateGlow = true
                    }
                
                // Main navigation bar
                HStack {
                    ForEach(0..<5) { index in
                        let icons = ["home", "magnifying", "camera", "shop", "person"]
                        let titles = ["Home", "Search", "Camera", "Shop", "Profile"]
                        
                        EnhancedTabBarButton(
                            icon: icons[index],
                            title: titles[index],
                            isSelected: selectedTab == index
                        ) {
                            // Animation: Bounce effect when selecting tab
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                                
                                // Haptic feedback
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                                
                                // Handle special tabs
                                if index == 2 { // Camera
                                    showCamera = true
                                } else if index == 3 { // Shop
                                    showWebView = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    // Enhanced glass effect background
                    ZStack {
                        // Blur layer
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.01))
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.15))
                                    .blur(radius: 10)
                            )
                        
                        // Main background
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.charlestonGreen.opacity(0.95))
                        
                        // Subtle highlight
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                // Animation: Hide/show on scroll
                .offset(y: tabBarOffset)
            }
        }
        // Sheet for WebView
        .sheet(isPresented: $showWebView) {
            WebViewScreen(showWebView: $showWebView)
        }
        // Sheet for Camera
        .sheet(isPresented: $showCamera) {
            Text("Camera View")
                .font(.title)
                .padding()
        }
    }
}

// MARK: - Enhanced Tab Bar Button
struct EnhancedTabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var bounceAnimation = false
    @State private var glowOpacity = 0.0

    var body: some View {
        Button(action: {
            action()
            // Trigger bounce animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bounceAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    bounceAnimation = false
                }
            }
        }) {
            VStack(spacing: 4) {
                // Enhanced icon with glow and animation
                ZStack {
                    // Glow effect for selected tab
                    if isSelected {
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .blur(radius: 4)
                            .opacity(glowOpacity)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: glowOpacity
                            )
                            .onAppear {
                                glowOpacity = 0.5
                            }
                    }
                    
                    // Icon
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isSelected ? .white : .gray.opacity(0.7))
                        .frame(width: 22, height: 22)
                        .scaleEffect(bounceAnimation && isSelected ? 1.2 : 1.0)
                }
                
                // Title with animation
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            // Enhanced indicator for selected tab
            .overlay(
                ZStack {
                    if isSelected {
                        // Pill indicator
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 25, height: 3)
                            .offset(y: 16)
                        
                        // Dot indicator
                        Circle()
                            .fill(Color.white)
                            .frame(width: 4, height: 4)
                            .offset(y: 16)
                    }
                },
                alignment: .bottom
            )
        }
    }
}

// MARK: - Enhanced WebView Screen
struct WebViewScreen: View {
    @Binding var showWebView: Bool
    let websiteURL = URL(string: "https://tlhome.co.uk")!
    @State private var isLoading = true
    @State private var loadingProgress = 0.0
    @State private var animateShimmer = false

    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: websiteURL)
                
                // Enhanced loading indicator with animation
                if isLoading {
                    ZStack {
                        // Background blur
                        Color.black.opacity(0.05)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 20) {
                            // Animated logo placeholder
                            ZStack {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.etonBlue.opacity(0.3), Color.etonBlue.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(loadingProgress))
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.etonBlue, Color.etonBlue.opacity(0.7)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                    )
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: loadingProgress)
                                
                                Image(systemName: "globe")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.etonBlue)
                            }
                            
                            Text("Loading Shop...")
                                .font(.headline)
                                .foregroundColor(.charlestonGreen)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                                )
                                // Shimmer effect
                                .overlay(
                                    GeometryReader { geometry in
                                        Color.white.opacity(0.3)
                                            .frame(width: 30)
                                            .blur(radius: 10)
                                            .rotationEffect(.degrees(30))
                                            .offset(x: animateShimmer ? geometry.size.width : -geometry.size.width)
                                            .animation(
                                                Animation.linear(duration: 1.5)
                                                    .repeatForever(autoreverses: false),
                                                value: animateShimmer
                                            )
                                    }
                                    .mask(
                                        Text("Loading Shop...")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    )
                                    .onAppear {
                                        animateShimmer = true
                                    }
                                )
                        }
                    }
                    .onAppear {
                        // Simulate loading progress
                        withAnimation(.easeInOut(duration: 2.5)) {
                            loadingProgress = 1.0
                        }
                        
                        // Simulate loading time
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Shop", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    showWebView = false
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.etonBlue)
                }
            )
        }
    }
}

// MARK: - Enhanced Floating Button
struct EnhancedFloatingButton: View {
    @Binding var isNavigating: Bool
    @State private var isAnimating = false
    @State private var rotationDegrees = 0.0
    @State private var glowOpacity = 0.0

    var body: some View {
        Button(action: {
            // Animation: Scale down on tap
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
                
                // Haptic feedback
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                // Delay navigation to allow animation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isNavigating = true
                    isAnimating = false
                }
            }
        }) {
            ZStack {
                // Enhanced outer glow with animation
                Circle()
                    .fill(Color.etonBlue.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .blur(radius: 5)
                    .opacity(glowOpacity)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: glowOpacity
                    )
                    .onAppear {
                        glowOpacity = 0.7
                    }
                
                // Rotating ring
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.etonBlue.opacity(0.7), Color.etonBlue.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 65, height: 65)
                    .rotationEffect(.degrees(rotationDegrees))
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 10)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotationDegrees = 360
                        }
                    }
                
                // Enhanced button background with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.etonBlue, Color.etonBlue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.etonBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(isAnimating ? 0.9 : 1.0)
                
                // Enhanced plus icon with animation
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 0.8 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 90 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            }
        }
        .padding()
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

