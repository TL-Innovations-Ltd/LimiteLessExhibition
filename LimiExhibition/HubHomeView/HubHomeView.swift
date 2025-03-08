//
//  HubHomeView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

struct HubHomeView: View {

    let hubs: [Hub] = [
        Hub(name: "Hub Controller"),

    ]
    
    var body: some View {
        ZStack {
            Color.etonBlue
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HubHeaderView(title: "")
                
                ScrollView {
                    ForEach(hubs) { room in
                        NavigationLink(destination: HomeDetailView(roomName: room.name)) {
                            
                           // HubCardView(room: room, bluetoothManager: bluetoothManager)
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
import SwiftUI


import SwiftUI














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
