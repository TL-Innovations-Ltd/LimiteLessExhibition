// MainCoordinator.swift
import SwiftUI

struct MainCoordinator: View {
    @StateObject private var roomDataModel = RoomDataModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Room Scanner & Lighting Placement")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Scan your room and place lighting fixtures")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: RoomScannerView().environmentObject(roomDataModel)) {
                    Text("Start Room Scan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
        }
    }
}
