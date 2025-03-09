import SwiftUI
import UIKit
import WebKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showGetStarted = false
    @State private var animateBackground = false
    private let totalPages = 3
    
    
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer() // Pushes content below // Pushes everything else below
                
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
                                image: "ceilingLight",
                                title: "Welcome to LIMI",
                                description: "Experience the future of smart lighting—customizable, modular, and effortless."

                            )
                            .tag(0)
                            
                            OnboardingPageView(
                                image: "nfcScan",
                                title: "Energy Efficient",
                                description: "Save energy and reduce costs with intelligent automation and scheduling."

                            )
                            .tag(1)
                            
                            OnboardingPageView(
                                image: "lock.shield.fill",
                                title: "Secure & Private",
                                description: "Your data stays private with end-to-end encryption and local processing."

                            )
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .animation(.easeInOut, value: currentPage)
                        .ignoresSafeArea()
                        
                        // Page indicator and buttons
                        VStack(spacing: 30) {
                            CustomPageIndicator(currentPage: currentPage, totalPages: totalPages, activeColor: Color.alabaster)
                                .padding(.top, 40)
                            
                            HStack {
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
                                        Text(currentPage < totalPages - 1 ? "" : "Get Started")
                                        
                                        if currentPage == totalPages - 1 {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .semibold))
                                        }else{
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                    .frame(width: currentPage < totalPages - 1 ? 120 : 150)
                                    .padding()
                                    
                                    .foregroundColor(.alabaster)
                                    .cornerRadius(16)
                                    .shadow(color: Color.alabaster.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
            .background(Color.verticalGradient)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
struct OnboardingPageView: View {
    let image: String
    let title: String
    let description: String

    
    @State private var imageScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    @State private var descriptionOffset: CGFloat = 20
    
    var body: some View {
        VStack {

            
            // Image with animation
            ZStack {
                if image == "nfcScan" {
                                // Show GIF when image is "nfcScan"
                                GIFView(gifName: "nfcScan") // Ensure you have nfcScan.gif in assets
                                    .frame(width: 300, height: 300)
                                    .scaleEffect(imageScale)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                                            imageScale = 1.0
                                        }
                                    }
                            } else {
                                // Show static Image for other values
                                Image(image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color.white)
                                    .scaleEffect(imageScale)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                                            imageScale = 1.0
                                        }
                                    }
                            }
            }
            .ignoresSafeArea()
            .padding(.bottom, 40)
            
            // Title with animation
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.alabaster.opacity(0.8))
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
                .foregroundColor(Color.alabaster.opacity(0.6))
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
        }
        .ignoresSafeArea()

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




struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

