//
//  LimiExhibitionApp.swift
//  LimiExhibition
//
//  Created by Mac Mini on 25/02/2025.
//

import SwiftUI
import SwiftData
import RoomPlan

@main
struct YourApp: App {
    
    var body: some Scene {
        WindowGroup {

            SplashScreen()
            
        }
    }
}



struct StartView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            HomeView()
        } else {
            VStack {
                Text("Limi")
                Text("First Time Launch")
            }
        }
    }
}
