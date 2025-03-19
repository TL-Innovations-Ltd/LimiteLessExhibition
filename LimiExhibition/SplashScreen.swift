import SwiftUI
import AVKit

struct SplashScreen: View {
    @State private var isActive = false
    @State private var animate = false
    
    var body: some View {
        if isActive {
            AnimationVideoViewPreview() // Ensure this view covers the entire screen
                .ignoresSafeArea()
        } else {
            ZStack {
                Color.charlestonGreen.ignoresSafeArea() // Background color
                
                VStack {
                    ZStack {
                        Image("logoSplash") // Static Logo (Touchable)
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
