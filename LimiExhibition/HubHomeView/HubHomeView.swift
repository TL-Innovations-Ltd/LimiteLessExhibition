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
                            HubCardView(room    : room)
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

struct HubCardView: View {
    @State private var isExpanded = false

    let room: Room
    var modHub = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("hub")
                    .resizable()
                    .frame(width: 80,height: 80)
                    .font(.title)
                
                    .foregroundColor(.charlestonGreen)
                
                Spacer()
                
                Text("\(room.devices)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
                    .foregroundColor(.charlestonGreen)
            }
            
            Spacer()
            
            if let connectedDevice = SharedDevice.shared.connectedDevice {
                VStack { // Wrapping in a VStack ensures the body returns a single View
                    Text("\(connectedDevice.name) (\(connectedDevice.id))")
                        .font(.headline)
                        .foregroundColor(.charlestonGreen)
                }
                .onAppear {
                    print("Connected Device: \(connectedDevice.name) (\(connectedDevice.id))") // ✅ Prints in console when View appears
                }
            }



            HStack {
                Text("\(room.devices) Devices")
                    .font(.caption)
                    .foregroundColor(.charlestonGreen.opacity(0.8))
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .foregroundColor(.white.opacity(0.8))
                                .transition(.opacity) // Fade effect
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                                .onTapGesture {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                }
                        }
                        
                    
            
    }
        .padding()
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.alabaster, .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        
        .shadow(color: Color.charlestonGreen.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HubHomeView()
}
