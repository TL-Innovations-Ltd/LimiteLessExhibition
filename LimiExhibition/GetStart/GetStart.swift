import SwiftUI

struct GetStart: View {
    @State private var selectedRole: Role? = nil
    @State private var isAnimating = false
    @State private var showGetStarted = false
    @State private var navigateToSignIn = false

    enum Role {
        case deafOrHardOfHearing
        case signLanguageInterpreter
    }
    
    var body: some View {
        ZStack {
            Color.etonBlue.ignoresSafeArea().opacity(0.6)
            
            VStack(spacing: 0) {
                // Animated Header
                Text("Choose your role\nbelow")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimating)
                
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 20) {
                        // First Role Card
                        RoleCard(
                            role: .deafOrHardOfHearing,
                            isSelected: selectedRole == .deafOrHardOfHearing,
                            action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                    selectedRole = .deafOrHardOfHearing
                                    showGetStarted = true
                                }
                            }
                        )
                        .offset(x: isAnimating ? 0 : -200)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                        
                        // Animated "or" text
                        Text("or")
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.vertical, 4)
                            .opacity(isAnimating ? 1 : 0)
                            .scaleEffect(isAnimating ? 1 : 0.5)
                            .animation(.spring(response: 0.5).delay(0.3), value: isAnimating)
                        
                        // Second Role Card
                        RoleCard(
                            role: .signLanguageInterpreter,
                            isSelected: selectedRole == .signLanguageInterpreter,
                            action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedRole = .signLanguageInterpreter
                                    showGetStarted = true
                                }
                            }
                        )
                        .offset(x: isAnimating ? 0 : 200)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.4), value: isAnimating)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                   
                }
                
                Spacer()
                
                // Get Started Button
                GetStartedButton(isEnabled: selectedRole != nil, isVisible: showGetStarted)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct RoleCard: View {
    let role: GetStart.Role
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Role illustration
                Group {
                    if role == .deafOrHardOfHearing {
                        DeafPersonIllustration(isSelected: isSelected)
                    } else {
                        InterpreterIllustration(isSelected: isSelected)
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(role == .deafOrHardOfHearing ? "Installer" : "User")
                        .font(.system(size: 16, weight: .medium))
                    Text(role == .deafOrHardOfHearing ? "Install the Electronics Equipment" : "Control the Electronics Equipment")
                        .font(.system(size: 8, weight: .medium))
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.emerald.opacity(0.6))
                    
                    // Selection indicator
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.charlestonGreen, lineWidth: isSelected ? 2 : 0)
                        .scaleEffect(isSelected ? 1 : 0.95)
                        .animation(.spring(response: 0.3), value: isSelected)
                }
            )
            .scaleEffect(isSelected ? 1.02 : (isHovered ? 1.01 : 1.0))
            .animation(.spring(response: 0.3), value: isSelected || isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct GetStartedButton: View {
    let isEnabled: Bool
    let isVisible: Bool
    @State private var navigateToSignIn = false
    @State private var navigateToDemo = false

    var body: some View {
        Button(action: {
            navigateToSignIn = true
        }) {
            HStack {
                Text("Get started")
                    .font(.system(size: 16, weight: .medium))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .opacity(isEnabled ? 1 : 0)
                    .scaleEffect(isEnabled ? 1 : 0.7)
                    .animation(.spring(response: 0.3), value: isEnabled)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.black : Color.gray.opacity(0.3))
                    .animation(.easeInOut(duration: 0.2), value: isEnabled)
            )
            .foregroundColor(.white)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isVisible)
        }
        .disabled(!isEnabled)
        .navigationDestination(isPresented: $navigateToDemo) {
            DemoView()
        }
        .fullScreenCover(isPresented: $navigateToSignIn) {
            AddDeviceView()
 // Replace this with your actual screen
        }
    }
    

}

struct DecorativeElements: View {
    let isAnimating: Bool
    @State private var starRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Stars
            ForEach(0..<3) { index in
                AnimatedStar(
                    delay: Double(index) * 0.2,
                    offsetX: [-120, 140, 140][index],
                    offsetY: [40, -180, 140][index],
                    size: [16, 20, 16][index],
                    color: index == 1 ? .blue : .yellow
                )
            }
            
            // Arrows
            Group {
                CurvedArrow()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(180))
                    .offset(x: -10, y: 30)
                
                CurvedArrow()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 60, height: 60)
                    .offset(x: -10, y: 220)
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeInOut(duration: 0.6).delay(0.5), value: isAnimating)
        }
    }
}

struct AnimatedStar: View {
    let delay: Double
    let offsetX: CGFloat
    let offsetY: CGFloat
    let size: CGFloat
    let color: Color
    
    @State private var isAnimating = false
    @State private var rotation = 0.0
    
    var body: some View {
        Star()
            .fill(color.opacity(0.8))
            .frame(width: size, height: size)
            .offset(x: offsetX, y: offsetY)
            .opacity(isAnimating ? 1 : 0)
            .scaleEffect(isAnimating ? 1 : 0.3)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.spring(response: 0.6).delay(delay)) {
                    isAnimating = true
                }
                withAnimation(
                    .linear(duration: 4)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    GetStart()
}
