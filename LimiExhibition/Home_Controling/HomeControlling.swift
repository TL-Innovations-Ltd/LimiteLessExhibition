import SwiftUI
struct HomeControlling: View {
    @State private var currentScreen: Screen = .controlPanel
    @State private var navigationStack: [Screen] = []
    
    enum Screen {
        case controlPanel
        case livingRoom
        case lightControl
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch currentScreen {
                case .controlPanel:
                    ControlPanelView(onRoomTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            navigateTo(.livingRoom)
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    
                case .livingRoom:
                    LivingRoomView(
                        onBackTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                navigateBack()
                            }
                        },
                        onLightTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                navigateTo(.lightControl)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    
                case .lightControl:
                    LightControlView(
                        onBackTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                navigateBack()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
            }
            .background(Color.backgroundColor)
        }
    }
    
    private func navigateTo(_ screen: Screen) {
        navigationStack.append(currentScreen)
        currentScreen = screen
    }
    
    private func navigateBack() {
        if let previousScreen = navigationStack.popLast() {
            currentScreen = previousScreen
        }
    }
}

#Preview {
    HomeControlling()
}

