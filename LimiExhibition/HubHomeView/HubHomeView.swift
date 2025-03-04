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
            Color.alabaster
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HubHeaderView(title: "Smart Hub")
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        ForEach(rooms) { room in
                            NavigationLink(destination: HomeDetailView(roomName: room.name)) {
                                RoomCardView(room: room)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
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
                    .foregroundColor(.emerald)
            }
        }
        .padding()
        .background(Color.alabaster)
    }
}

struct RoomCardView: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: room.icon)
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(room.devices)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.white.opacity(0.3))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(room.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(room.devices) Devices")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(height: 160)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.emerald, .etonBlue]),
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
