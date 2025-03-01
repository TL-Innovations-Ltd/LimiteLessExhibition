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
                Color.alabaster.ignoresSafeArea() // Background color
                
                VStack {
                    ZStack {
                        Image("logoSplash") // Static Logo (Touchable)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .padding()
                            .shadow(radius: 10)
                            .offset(y: 10) // Adjust position
                            .opacity(animate ? 0.3 : 1.0) // Fading effect
                            .scaleEffect(animate ? 1.0 : 0.5) // Scaling effect
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)
                            .onAppear {
                                animate = true
                            }
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
