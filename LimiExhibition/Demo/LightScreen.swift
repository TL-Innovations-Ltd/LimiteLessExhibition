import SwiftUI

struct LightCard: View {
    let lightName: String
    @State private var isOn: Bool = false
    @State private var isAIEnabled: Bool = false
    @State private var showToast: Bool = false
    @State private var brightness: Double = 1.0
    @State private var animate = false

    var body: some View {
        VStack(spacing: 16) {
            // Light Toggle Card
            HStack {
                Text(lightName)
                    .font(.headline)
                    .foregroundColor(.charlestonGreen)
                Spacer()
                Toggle(isOn: $isOn) {
                    Text(isOn ? "On" : "Off")
                        .foregroundColor(isOn ? .green : .red)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .disabled(isAIEnabled) // Disable when AI is ON
                .labelsHidden()
            }
            .padding()
            .background(Color.white.opacity(brightness))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

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
        }
        .padding()
        .onChange(of: isAIEnabled) { _ in
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showToast = false
                }
            }
        }
        .onAppear {
            if isAIEnabled {
                startAIMode()
            }
        }
    }

    // MARK: - AI Mode Animation
    func startAIMode() {
        animate = true
        runLightAnimation()
    }

    func stopAIMode() {
        animate = false
        brightness = 1.0
    }

    func runLightAnimation() {
        guard animate else { return }
        withAnimation(.easeInOut(duration: 2.0)) {
            brightness = brightness == 1.0 ? 0.5 : 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            runLightAnimation()
        }
    }
}
