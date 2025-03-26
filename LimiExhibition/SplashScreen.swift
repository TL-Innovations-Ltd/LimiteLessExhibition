import SwiftUI
import AVKit

struct SplashScreen: View {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @StateObject private var authManager = AuthManager.shared

    @State private var isActive = false
    @State private var animate = false

    var body: some View {
        if isActive {
            if authManager.isAuthenticated {
                HomeView()
                    .ignoresSafeArea()
            } else if !hasLaunchedBefore {
                AnimationVideoViewPreview()
                    .ignoresSafeArea()
                    .onAppear {
                        hasLaunchedBefore = true
                    }
            } else {
                GetStart()
                    .ignoresSafeArea()
            }
        } else {
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
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
