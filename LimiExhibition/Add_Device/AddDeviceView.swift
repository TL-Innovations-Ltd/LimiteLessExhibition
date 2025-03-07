import SwiftUI

struct AddDeviceView: View {
    @State private var currentScreen: Screen = .addDevices
    @State private var scanProgress: Double = 0
    @State private var isAnimating = false
    
    enum Screen {
        case addDevices
        case scanning
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.etonBlue.edgesIgnoringSafeArea(.all)
                
                
                if currentScreen == .addDevices {
                    AddDevicesView(onOptionSelected: { option in
                        if option == .nearby {
                            withAnimation {
                                currentScreen = .scanning
                                startScanningAnimation()
                            }
                        }
                    })
                } else {
                    ScanningView(
                        progress: scanProgress,
                        isAnimating: isAnimating,
                        onBack: {
                            withAnimation {
                                currentScreen = .addDevices
                            }
                        }
                    )
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func startScanningAnimation() {
        isAnimating = true
        
        // Simulate progress increasing over time
        scanProgress = 0
        
        withAnimation(.easeInOut(duration: 5)) {
            scanProgress = 0.18 // 18%
        }
        
        // Continue animation to 100% after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeInOut(duration: 15)) {
                scanProgress = 1.0
            }
        }
    }
}

struct AddDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        AddDeviceView()
    }
}

