//
//  EnhancedBottomNavigationView.swift
//  Limi
//
//  Created by Mac Mini on 18/04/2025.
//


import SwiftUI
// MARK: - Bottom Navigation Component
struct EnhancedBottomNavigationView: View {
    @Binding var showARScan: Bool
    @Binding var showCustomer: Bool
    @Binding var showGrouping: Bool
    @Binding var showWebView: Bool
    @Binding var selectedTab: Int
    @Binding var isLoaded: Bool
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var tabBarOffset: CGFloat = 0
    @State private var previousScrollOffset: CGFloat = 0
    @State private var animateGlow = false
    
    var body: some View {
        VStack {
            Spacer()
            // Enhanced bottom navigation bar with glass effect
            ZStack {
                // Animated glow effect
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.eton.opacity(0.2))
                    .blur(radius: 10)
                    .frame(height: 70)
                    .padding(.horizontal, 10)
                    .opacity(animateGlow ? 0.5 : 0.2)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: animateGlow
                    )
                    .onAppear {
                        animateGlow = true
                    }
                
                // Main navigation bar
                HStack {
                    ForEach(0..<5) { index in
                        let icons = ["home", "group", "camera", "shop", "person"]
                        let titles = ["Home", "Group", "AR Scan", "Website", "Customer"]
                        
                        EnhancedTabBarButton(
                            icon: icons[index],
                            title: titles[index],
                            isSelected: selectedTab == index
                        ) {
                            // Animation: Bounce effect when selecting tab
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                                
                                // Haptic feedback
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                                
                                // Handle special tabs
                                if index == 2 { // AR Scan
                                    showARScan = true
                                }
                                else if index == 3 { // Shop
                                    showWebView = true
                                }
                                else if index == 4 { // Shop
                                    showCustomer = true
                                }
                                else if index == 1 { // Group
                                    showGrouping = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    // Enhanced glass effect background
                    ZStack {
                        // Blur layer
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.01))
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.15))
                                    .blur(radius: 10)
                            )
                        
                        // Main background
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.charlestonGreen.opacity(0.95))
                        
                        // Subtle highlight
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                // Animation: Hide/show on scroll
                .offset(y: tabBarOffset)
            }
        }
        .offset(y: isLoaded ? 0 : 100)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: isLoaded)
        // Sheet for WebView
        .sheet(isPresented: $showWebView) {
            WebViewScreen(showWebView: $showWebView)
        }
        // Sheet for Camera
        .sheet(isPresented: $showGrouping) {
            GroupingView()
        }
        .sheet(isPresented: $showCustomer) {
            CustomerCaptureView()
        }
    }
}
