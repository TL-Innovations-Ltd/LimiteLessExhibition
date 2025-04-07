import SwiftUI

struct DemoHomeView: View {
    @State private var rooms: [DemoRoom] = [
        DemoRoom(name: "Living Room", devices: [
            DemoDevice(id: "1", name: "Bela Lampe", type: .pendantLight, isOn: true, brightness: 80, colorTemperature: 0.3),
            DemoDevice(id: "2", name: "RGB Led", type: .rgbLight, isOn: true, brightness: 1, color: .red)
        ]),
        DemoRoom(name: "Bedroom", devices: [
            DemoDevice(id: "3", name: "Bedside Lamp", type: .light, isOn: false, brightness: 40)
        ]),
        DemoRoom(name: "Kitchen", devices: [
            DemoDevice(id: "4", name: "Ceiling Light", type: .light, isOn: true, brightness: 100, colorTemperature: 0.7)
        ])
    ]
    
    @State private var showingAddDevice = false
    @State private var selectedDevice: DemoDevice? = nil
    @State private var searchText = ""

    //header
    @State private var isSidebarOpen = false
    @State private var headerOffset: CGFloat = -100
    // Animation states
    @State private var isLoaded = false
    @State private var searchFieldFocused = false
    @State private var shimmerAnimation = false // For shimmer effect
    var body: some View {
        ZStack {
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

            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
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
                    Text("My Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(rooms) { room in
                        roomSection(room)
                    }
                }
                .padding(.vertical)
            }
            
            if let device = selectedDevice {
                if device.type == .pendantLight {
                    DemoPendantLightControlView(device: device, isPresented: Binding(
                        get: { selectedDevice != nil },
                        set: { if !$0 { selectedDevice = nil } }
                    ))
                    .transition(.opacity)
                } else if device.type == .rgbLight {
                    DemoRGBLightControlView(device: device, isPresented: Binding(
                        get: { selectedDevice != nil },
                        set: { if !$0 { selectedDevice = nil } }
                    ))
                    .transition(.opacity)
                } else {
                    DemoDeviceControlView(device: device)
                        .background(
                            Color.black.opacity(0.5)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    selectedDevice = nil
                                }
                        )
                        .transition(.opacity)
                }
            }
        }
        .sheet(isPresented: $showingAddDevice) {
            DemoAddDeviceView { newDevice in
                if let firstRoom = rooms.first {
                    var updatedRoom = firstRoom
                    updatedRoom.devices.append(newDevice)
                    if let index = rooms.firstIndex(where: { $0.id == firstRoom.id }) {
                        rooms[index] = updatedRoom
                    }
                }
            }
        }
    }
    
    private func roomSection(_ room: DemoRoom) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            
            Text(room.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(room.devices) { device in
                        deviceCard(device)
                    }
                    
                    addDeviceButton
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func deviceCard(_ device: DemoDevice) -> some View {
        Button(action: {
            selectedDevice = device
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.headline)
                            .foregroundColor(.charlestonGreen)
                        
                        Text(device.isOn ? "On" : "Off")
                            .font(.subheadline)
                            .foregroundColor(.charlestonGreen)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { device.isOn },
                        set: { newValue in
                            if let index = rooms.firstIndex(where: { room in
                                room.devices.contains(where: { $0.id == device.id })
                            }) {
                                if let deviceIndex = rooms[index].devices.firstIndex(where: { $0.id == device.id }) {
                                    rooms[index].devices[deviceIndex].isOn = newValue
                                }
                            }
                        }
                    ))
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                
                deviceImage(device)
                
                if device.isOn {
                    brightnessBar(device)
                }
            }
            .padding()
            .frame(width: 160, height: 200)
            .background(Color.alabaster)
            .cornerRadius(15)
        }
    }
    
    private func deviceImage(_ device: DemoDevice) -> some View {
        ZStack {
//            if device.type == .pendantLight || device.type == .rgbLight {
//                Image(systemName: "lightbulb.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(device.isOn ? (device.type == .rgbLight ? device.color : .yellow) : .gray)
//                    .frame(height: 60)
//            } else {
//                Image(systemName: device.iconName)
//                    .font(.system(size: 40))
//                    .foregroundColor(device.isOn ? .yellow : .gray)
//                    .frame(height: 60)
//            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func brightnessBar(_ device: DemoDevice) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(white: 0.3))
                    .frame(height: 5)
                    .cornerRadius(2.5)
                
                Rectangle()
                    .fill(device.type == .rgbLight ? device.color : Color.yellow)
                    .frame(width: geometry.size.width * CGFloat(device.brightness / 100), height: 5)
                    .cornerRadius(2.5)
            }
        }
        .frame(height: 5)
    }
    
    private var addDeviceButton: some View {
        Button(action: {
            showingAddDevice = true
        }) {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                
                Text("Add Device")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(width: 120, height: 200)
            .background(Color(white: 0.15))
            .cornerRadius(15)
        }
    }
}



struct DemoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DemoHomeView()
    }
}

