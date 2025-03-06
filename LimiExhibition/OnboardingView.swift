import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showGetStarted = false
    @State private var animateBackground = false
    private let totalPages = 3
    
    // Define custom colors

    let roseRed = Color(hex: "FF6B6B")
    let yellowCrayola = Color(hex: "FFCC5C")
    
    var body: some View {
        ZStack {
            // Animated background
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.etonBlue.opacity(0.3))
                        .frame(width: geometry.size.width * 0.8)
                        .offset(x: animateBackground ? -geometry.size.width * 0.5 : -geometry.size.width * 0.7,
                                y: animateBackground ? -geometry.size.height * 0.2 : -geometry.size.height * 0.3)
                        .blur(radius: 60)
                    
                    Circle()
                        .fill(roseRed.opacity(0.2))
                        .frame(width: geometry.size.width * 0.7)
                        .offset(x: animateBackground ? geometry.size.width * 0.4 : geometry.size.width * 0.6,
                                y: animateBackground ? geometry.size.height * 0.3 : geometry.size.height * 0.4)
                        .blur(radius: 70)
                    
                    Circle()
                        .fill(yellowCrayola.opacity(0.2))
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: animateBackground ? -geometry.size.width * 0.1 : -geometry.size.width * 0.2,
                                y: animateBackground ? geometry.size.height * 0.5 : geometry.size.height * 0.6)
                        .blur(radius: 50)
                }
                .animation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateBackground)
            }
            .ignoresSafeArea()
            .onAppear {
                animateBackground = true
            }
            
            // Main content
            VStack {
                if showGetStarted {
                    GetStart()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    TabView(selection: $currentPage) {
                        OnboardingPageView(
                            image: "house.fill",
                            title: "Smart Home Control",
                            description: "Manage your entire home with a simple tap. Control lights, temperature, and security.",
                            accentColor: Color.etonBlue
                        )
                        .tag(0)
                        
                        OnboardingPageView(
                            image: "bolt.fill",
                            title: "Energy Efficient",
                            description: "Save energy and reduce costs with intelligent automation and scheduling.",
                            accentColor: roseRed
                        )
                        .tag(1)
                        
                        OnboardingPageView(
                            image: "lock.shield.fill",
                            title: "Secure & Private",
                            description: "Your data stays private with end-to-end encryption and local processing.",
                            accentColor: yellowCrayola
                        )
                        .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Page indicator and buttons
                    VStack(spacing: 30) {
                        CustomPageIndicator(currentPage: currentPage, totalPages: totalPages, activeColor: Color.etonBlue)
                            .padding(.top, 20)
                        
                        HStack {
                            Button("Skip") {
                                withAnimation(.spring()) {
                                    showGetStarted = true
                                }
                            }
                            .foregroundColor(Color.charlestonGreen)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button(action: {
                                if currentPage < totalPages - 1 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        showGetStarted = true
                                    }
                                }
                            }) {
                                HStack {
                                    Text(currentPage < totalPages - 1 ? "Next" : "Get Started")
                                    
                                    if currentPage == totalPages - 1 {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .frame(width: currentPage < totalPages - 1 ? 120 : 150)
                                .padding()
                                .background(Color.etonBlue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.etonBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .background(Color.alabaster)
    }
}

struct OnboardingPageView: View {
    let image: String
    let title: String
    let description: String
    let accentColor: Color
    
    @State private var imageScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    @State private var descriptionOffset: CGFloat = 20
    
    var body: some View {
        VStack {
            Spacer()
            
            // Image with animation
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 280, height: 280)
                
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(accentColor)
                    .scaleEffect(imageScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            imageScale = 1.0
                        }
                    }
            }
            .padding(.bottom, 40)
            
            // Title with animation
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.black.opacity(0.8))
                .padding(.top, 20)
                .opacity(textOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                        textOpacity = 1
                    }
                }
            
            // Description with animation
            Text(description)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.black.opacity(0.6))
                .padding(.horizontal, 40)
                .padding(.top, 16)
                .offset(y: descriptionOffset)
                .opacity(textOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                        descriptionOffset = 0
                        textOpacity = 1
                    }
                }
            
            Spacer()
            Spacer()
        }
    }
}

struct CustomPageIndicator: View {
    var currentPage: Int
    var totalPages: Int
    var activeColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { index in
                if currentPage == index {
                    Capsule()
                        .fill(activeColor)
                        .frame(width: 24, height: 8)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.spring(), value: currentPage)
    }
}


// Extension to create Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

