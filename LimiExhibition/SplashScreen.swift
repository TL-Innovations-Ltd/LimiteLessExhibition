import SwiftUI
import AVKit

struct SplashScreen: View {
    @StateObject private var authManager = AuthManager.shared
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            if authManager.isAuthenticated {
                HomeView()
                    .ignoresSafeArea()
            } else if !hasLaunchedBefore {
                // First-time user
                AnimationVideoViewPreview()
                    .ignoresSafeArea()
            } else if !hasCompletedOnboarding {
                OnboardingView()
                    .ignoresSafeArea()
            } else {
                GetStart()
                    .ignoresSafeArea()
            }
        } else {
            // Splash Screen
            ZStack {
                Color.charlestonGreen.ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Image("logoSplash")
                            .resizable()
                            .frame(width: 120, height: 100)
                            .padding()
                            .shadow(radius: 20)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isActive = true
                }
            }
        }
    }
}
#Preview {
    SplashScreen()
}
