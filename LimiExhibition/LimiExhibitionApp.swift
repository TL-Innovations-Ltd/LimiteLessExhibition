//
//  LimiExhibitionApp.swift
//  LimiExhibition
//
//  Created by Mac Mini on 25/02/2025.
//

import SwiftUI

@main
struct YourApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    var body: some Scene {
        WindowGroup {
            if !hasLaunchedBefore {
                StartView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            hasLaunchedBefore = true
                        }
                    }
            } else {
                SplashScreen()
            }
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
                Text("Start View")
                Text("First Time Launch")
            }
        }
    }
}

