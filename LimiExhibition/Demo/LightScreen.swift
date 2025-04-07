import SwiftUI

struct LightScreen: View {
    @State private var isLoaded = false
    @State private var searchFieldFocused = false
    @State private var headerOffset: CGFloat = -100
    @State private var shimmerAnimation = false
    @State private var isAIEnabled: Bool = false
    @State private var showToast: Bool = false
    @State private var lightNames: [String] = ["Lana Pendant Light", "Astoria Pendant Light", "Oceana Small Ceiling Light"]
    @State private var isSearching: Bool = false // State to track if we're searching for lights
    @State private var selectedLight: String? = nil // Selected light after search

    var body: some View {
        VStack {
            ZStack {
                // Base gradient
                LinearGradient(gradient: Gradient(colors: [Color.charlestonGreen.opacity(0.8), Color.alabaster.opacity(0.9)]),
                               startPoint: .top,
                               endPoint: .bottom)
                
                // Animated shimmer effect
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

                    // Add Light Button
                    Button(action: {
                        isSearching = true
                        searchForDevices()
                    }) {
                        Text("Add Light")
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 80, height: 30)
                            .background(Color.emerald)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    // Show Searching View
                    if isSearching {
                        Text("Searching for devices...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    } else if let selectedLight = selectedLight {
                        // Once a device is selected, show the light card
                        LightCard(lightName: selectedLight, isAIEnabled: $isAIEnabled)
                            .padding(.horizontal)
                    } else {
                        // Show existing lights
                        ForEach(lightNames, id: \.self) { lightName in
                            LightCard(lightName: lightName, isAIEnabled: $isAIEnabled)
                                .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("Lights")
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

    func searchForDevices() {
        // Simulate a device search process with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // After searching, display the device list
            isSearching = false
            selectedLight = "New Light \(lightNames.count + 1)" // Simulate device selection
            lightNames.append(selectedLight!) // Add selected device to the list
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

