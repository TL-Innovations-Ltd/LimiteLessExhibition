import SwiftUI

struct LightScreen: View {
    let title: String
    @State private var isLoaded = false
    @State private var searchFieldFocused = false
    @State private var headerOffset: CGFloat = -100
    @State private var shimmerAnimation = false
    @State private var isAIEnabled: Bool = false
    @State private var showToast: Bool = false
    @State private var lightNames: [String] = ["Lana Pendant Light", "Astoria Pendant Light", "Oceana Small Ceiling Light"]
    @State private var isSearching: Bool = false
    @State private var lightStatus: [Bool] = [false, false, false] // light on/off status

    var body: some View {
        VStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.charlestonGreen.opacity(0.8), Color.alabaster.opacity(0.9)]),
                               startPoint: .top,
                               endPoint: .bottom)
                
                RadialGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.width * 1.3
                )
                .scaleEffect(shimmerAnimation ? 1.2 : 0.8)
                .opacity(shimmerAnimation ? 0.7 : 0.3)
                .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true), value: shimmerAnimation)
                .onAppear {
                    shimmerAnimation = true
                }

                VStack {
                    Text(title)
                        .font(.largeTitle)
                        .padding()

//                    // LIMI AI Button
//                    Button(action: {
//                        isAIEnabled.toggle()
//                        if isAIEnabled {
//                            startAIMode()
//                        } else {
//                            stopAIMode()
//                        }
//                    }) {
//                        Text("LIMI AI")
//                            .fontWeight(.bold)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(isAIEnabled ? Color.green : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .padding()

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

                    Button(action: {
                        isSearching = true
                        searchForDevices()
                    }) {
                        Text("Add Device")
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: 150, height: 60)
                            .background(Color.emerald)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    if isSearching {
                        Text("Searching for devices...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    } else {
                        ForEach(lightNames.indices, id: \.self) { index in
                            LightCard(
                                lightName: lightNames[index],
                                index: index, // 🔁 Pass index here
                                isAIEnabled: $isAIEnabled
                            )
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newLight = "New Light \(lightNames.count + 1)"
            lightNames.append(newLight)
            lightStatus.append(false) // Add status for new light
            isSearching = false
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

        for index in lightNames.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
                if isAIEnabled {
                    lightStatus[index] = true
                }
            }
        }
    }

    func stopAIMode() {
        for index in lightStatus.indices {
            lightStatus[index] = false
        }
        showToast = false
    }
}
