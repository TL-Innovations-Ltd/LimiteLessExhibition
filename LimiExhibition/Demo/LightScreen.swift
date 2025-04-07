import SwiftUI

struct LightScreen: View {
    // Animation states
    @State private var isLoaded = false
    @State private var searchFieldFocused = false
    @State private var headerOffset: CGFloat = -100
    @State private var shimmerAnimation = false // For shimmer effect
    @State private var isAIEnabled: Bool = false // State to track LIMI AI toggle
    @State private var showToast: Bool = false
    @State private var lightNames: [String] = ["Light 1", "Light 2", "Light 3"] // State to keep track of lights

    var body: some View {
        VStack {
            // MARK: - Enhanced Background with Animated Gradient
            ZStack {
                // Base gradient
                LinearGradient(gradient: Gradient(colors: [Color.charlestonGreen.opacity(0.8), Color.alabaster.opacity(0.9)]),
                               startPoint: .top,
                               endPoint: .bottom)
                
                // Animated overlay gradient for dynamic effect
                RadialGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.width * 1.3
                )
                .scaleEffect(shimmerAnimation ? 1.2 : 0.8)
                .opacity(shimmerAnimation ? 0.7 : 0.3)
                .animation(
                    Animation.easeInOut(duration: 4)
                        .repeatForever(autoreverses: true),
                    value: shimmerAnimation
                )
                .onAppear {
                    shimmerAnimation = true
                }
                
                // Subtle pattern overlay
                ZStack {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: CGFloat.random(in: 100...200))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                    }
                }

                VStack {
                    Text("Light Control")
                        .font(.largeTitle)
                        .padding()

                    // LIMI AI Button
                    Button(action: {
                        isAIEnabled.toggle()
                        if isAIEnabled {
                            startAIMode()
                        } else {
                            stopAIMode()
                        }
                    }) {
                        Text("LIMI AI")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isAIEnabled ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // Toast Message
                    if showToast {
                        Text("AI adjusting environment…")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                    }

                    // Lights
                    ForEach(lightNames, id: \.self) { lightName in
                        LightCard(lightName: lightName, isAIEnabled: $isAIEnabled)
                            .padding(.horizontal)
                    }
                    
                    // Add Light Button
                    Button(action: {
                        let newLightName = "Light \(lightNames.count + 1)"
                        lightNames.append(newLightName) // Add a new light
                    }) {
                        Text("Add Light")
                            .fontWeight(.bold)
                            .padding()
                            .frame(width:80, height: 30)
                            .background(Color.emerald)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Lights")
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

    // MARK: - AI Mode Logic
    func startAIMode() {
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showToast = false
            }
        }
    }

    func stopAIMode() {
        showToast = false
    }
}
