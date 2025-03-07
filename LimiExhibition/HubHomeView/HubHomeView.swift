//
//  HubHomeView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

struct HubHomeView: View {

    let rooms: [Room] = [
        Room(name: "Hub Controller", icon: "sofa.fill", devices: 4),

    ]
    
    var body: some View {
        ZStack {
            Color.etonBlue
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HubHeaderView(title: "Smart Hub")
                
                ScrollView {
                    ForEach(rooms) { room in
                        NavigationLink(destination: HomeDetailView(roomName: room.name)) {
                            
                            HubCardView(room: room)
                        }
                        .buttonStyle(PlainButtonStyle())
                    
                    }.padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct HubHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
            
            Spacer()
            
            Button(action: {
                // Settings action
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.charlestonGreen)
            }
        }
        .padding()
        .background(Color.etonBlue)
    }
}
    
import SwiftUI

struct HubCardView: View {
    @State private var isExpanded = false
    @State private var showAlert = false
    @State private var showModeAlert = false
    @State private var isAnimating = true
    @State private var buttonOpacity = 0.2
    @AppStorage("selectedMode") private var selectedMode: String?

    let room: Room
    var modHub = false
    
    var destinationView: some View {
        switch selectedMode {
        case "PWM":
            return AnyView(PWM2LEDView())
        case "RGB":
            return AnyView(DataRGBView())
        case "MiniController":
            return AnyView(MiniControllerView())
        default:
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        NavigationLink(destination: destinationView, isActive: Binding(
            get: { selectedMode != nil },
            set: { if !$0 { selectedMode = nil } }
        )) {
            VStack(alignment: .leading) {
                HStack {
                    Image("hub")
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    if let connectedDevice = SharedDevice.shared.connectedDevice {
                        VStack {
                            Text("\(connectedDevice.name)")
                                .font(.headline)
                        }
                        .onAppear {
                            print("Connected Device: \(connectedDevice.name)")
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(room.devices)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(6)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        if selectedMode == nil {
                            showAlert = true
                        }
                    }) {
                        Text(selectedMode == nil ? "Mode" : "Mode: \(selectedMode!)")
                            .font(.title)
                            .foregroundColor(.charlestonGreen)
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
            .frame(height: 200)
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
        }
        .simultaneousGesture(TapGesture().onEnded {
            if selectedMode == nil {
                showModeAlert = true
            }
        })
        .alert("Please select a mode first", isPresented: $showModeAlert) {
            Button("OK", role: .cancel) { }
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
        showAlert = false // Dismiss confirmation dialog first

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Slight delay
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
    }
}











struct HubContentView: View {
    var body: some View {
        NavigationStack {
            HubHomeView()
        }
    }
}

#Preview {

    HubContentView()
    
}
