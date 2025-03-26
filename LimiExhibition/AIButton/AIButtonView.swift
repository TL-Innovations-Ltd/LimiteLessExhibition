import SwiftUI

struct AIButtonView: View {
    @State private var isAIModeActive = false
    @State private var showPopup = false
    @ObservedObject var storeHistory = StoreHistory()
    let hub: Hub
    
    // Timer for replaying actions
    @State private var replayTimer: Timer?
    @State private var currentReplayIndex = 0
  
    var body: some View {
        ZStack {
            if isAIModeActive {
                // Overlay to dim other controls
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }

            VStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAIModeActive.toggle()
                        if isAIModeActive {
                            startReplaySequence()
                        } else {
                            stopReplaySequence()
                        }
                    }
                }) {
                    Image("aiButton")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(isAIModeActive ? .blue : .gray)
                        .scaleEffect(isAIModeActive ? 1.2 : 1.0)
                        // Glowing halo effect
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .blur(radius: 15)
                                .opacity(isAIModeActive ? 0.5 : 0)
                                .scaleEffect(1.5)
                        )
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAIModeActive)
                }
            }
        }
        .onDisappear {
            stopReplaySequence()
        }
    }
    
    private func startReplaySequence() {
        guard let queueElements = storeHistory.queues[hub.id] else { return }
        currentReplayIndex = 0
        
        replayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard currentReplayIndex < queueElements.count else {
                stopReplaySequence()
                return
            }
            
            let element = queueElements[currentReplayIndex]
            sendMessage(hub: hub, message: element.byteArray)
            currentReplayIndex += 1
        }
    }
    
    private func stopReplaySequence() {
        replayTimer?.invalidate()
        replayTimer = nil
        currentReplayIndex = 0
    }
    
    private func sendMessage(hub: Hub, message: [UInt8]) {
        if let connectedDevice = BluetoothManager.shared.connectedDevices[hub.id] {
            BluetoothManager.shared.sendMessageToDevice(to: hub.id, message: message)
        }
    }
}

struct AIButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AIButtonView(hub: Hub(name: "Test Hub"))
    }
}
