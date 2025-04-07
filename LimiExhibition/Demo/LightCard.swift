import SwiftUI

struct LightCard: View {
    let lightName: String
    @Binding var isAIEnabled: Bool // Track AI state
    @State private var isOn: Bool = false
    @State private var brightness: Double = 1.0
    @State private var animate = false
    @State private var isNavigatingToPWM = false // Track navigation state

    var body: some View {
        VStack(spacing: 16) {
            // Light Toggle Card
            HStack {
                Text(lightName)
                    .font(.headline)
                    .foregroundColor(.charlestonGreen)
                Spacer()
                
                // Toggle Switch for Light
                Toggle(isOn: $isOn) {
                    Text(isOn ? "On" : "Off")
                        .foregroundColor(isOn ? .green : .red)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .disabled(isAIEnabled) // Disable manual toggle when AI is ON
                .labelsHidden()
                
                // Navigation Link that opens PWMControllerView
                NavigationLink(
                    destination: PWMControllerView(lightName: lightName, isOn: $isOn),
                    isActive: $isNavigatingToPWM
                ) {
                    EmptyView()
                }
            }
            .padding()
            .background(Color.white.opacity(brightness))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .onChange(of: isAIEnabled) { _ in
            if isAIEnabled {
                startAIMode()
            } else {
                stopAIMode()
            }
        }
        .onTapGesture {
            // Trigger navigation to PWMControllerView when the card is tapped
            isNavigatingToPWM = true
        }
    }

    // MARK: - AI Mode Animation and Light Toggle
    func startAIMode() {
        animate = true
        runLightAnimation()
        runAutoToggleLoop()
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

    func runAutoToggleLoop() {
        Task {
            while isAIEnabled {
                isOn.toggle()
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds delay
            }
        }
    }
}

// Example of PWMControllerView
struct PWMControllerView: View {
    let lightName: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack {
            Text("PWM Controller for \(lightName)")
                .font(.largeTitle)
                .padding()
            
            Toggle(isOn: $isOn) {
                Text("Light is \(isOn ? "On" : "Off")")
                    .font(.title)
            }
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .padding()

            // You can add additional controls related to PWM if needed
            // For example, a slider to control brightness, etc.
            Slider(value: .constant(0.5), in: 0...1) {
                Text("Brightness")
            }
            .padding()

            Spacer()
        }
        .navigationTitle("PWM Control")
    }
}
