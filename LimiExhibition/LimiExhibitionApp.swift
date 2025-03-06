//
//  LimiExhibitionApp.swift
//  LimiExhibition
//
//  Created by Mac Mini on 25/02/2025.
//

import SwiftUI

@main
struct LimiExhibitionApp: App {
    var sharedUsername: String?

    init() {
        UINavigationBar.appearance().tintColor = UIColor.black  // ✅ Change back button color globally
    }
    
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                HomeView()
            } else {
                SplashScreen()
            }

        }
    }
}
