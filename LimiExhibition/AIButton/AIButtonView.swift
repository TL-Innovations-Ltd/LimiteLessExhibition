import SwiftUI

struct AIButtonView: View {
    @State private var isAIModeActive = false
    @State private var showPopup = false
    @ObservedObject var storeHistory = StoreHistory()
    let hub: Hub

    var body: some View {
        ZStack {
            if isAIModeActive {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                Spacer()

                Button(action: {
                    withAnimation {
                        isAIModeActive.toggle()
                        showPopup = true
                    }
                }) {
                    Image("aiButton")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(isAIModeActive ? .blue : .gray)
                        .scaleEffect(isAIModeActive ? 1.2 : 1.0)
                        .shadow(color: isAIModeActive ? .blue : .gray, radius: isAIModeActive ? 10 : 5)
                        .opacity(isAIModeActive ? 1.0 : 0.7)
                }
                .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAIModeActive)
                .sheet(isPresented: $showPopup) {
                    AIButtonPopupView(storeHistory: storeHistory, hub: hub)
                }

                Spacer()
            }
        }
    }
}

struct AIButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AIButtonView(hub: Hub(name: "Test Hub"))
    }
}
