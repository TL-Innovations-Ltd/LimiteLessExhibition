import SwiftUI
import UIKit
import WebKit

class ImageRotationCeiling: ObservableObject {
    @Published var currentIndex = 0
    private var timer: Timer?

    let images = ["ceilingVertical", "ceilingHorizontal"]

    init() {
        startImageRotation()
    }

    func startImageRotation() {
        stopImageRotation() // Stop any existing timer before starting a new one
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.currentIndex = (self.currentIndex + 1) % self.images.count
            }
        }
    }

    func stopImageRotation() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopImageRotation() // Ensure timer is stopped when the object is deallocated
    }
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showGetStarted = false
    @State private var animateBackground = false
    private let totalPages = 5
    
    var body: some View {
        ZStack {
            VStack {
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
                                image: "ceilingHorizaontal",
                                title: "Welcome to LIMI",
                                description: "Experience the future of smart lighting—customizable, modular, and effortless."
                            )
                            .tag(0)
                            
                            OnboardingPageView(
                                image: "second",
                                title: "Seamless Setup & Control",
                                description: "Scan a QR code, tap NFC, or connect via BLE or Wi-Fi for instant control."
                            )
                            .tag(1)
                            
                            OnboardingPageView(
                                image: "third",
                                title: "Design & Visualize",
                                description: "Use AR & 3D tools to create and preview your perfect lighting setup before buying."
                            )
                            .tag(2)
                            
                            OnboardingPageView(
                                image: "fourth",
                                title: "Smart Scheduling",
                                description: "Create routines that adapt to your lifestyle."
                            )
                            .tag(3)
                            
                            OnboardingPageView(
                                image: "fifth",
                                title: "You’re All Set!",
                                description: "Begin exploring, designing, and controlling your lights now."
                            )
                            .tag(4)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .animation(.easeInOut, value: currentPage)
                        .ignoresSafeArea()
                        
                        // Page indicator and buttons
                        VStack() {
                            CustomPageIndicator(currentPage: currentPage, totalPages: totalPages, activeColor: Color.charlestonGreen, inactiveColor: Color.charlestonGreen.opacity(0.6))
                                .padding(.top, 10)
                            
                            HStack {
                                Button(action: {
                                    if currentPage < totalPages - 1 {
                                        withAnimation {
                                            currentPage += 1
                                        }
                                    } else {
                                        withAnimation() {
                                            showGetStarted = true
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(currentPage < totalPages - 1 ? "" : "Get Started")
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .frame(width: 120)
                                    .padding()
                                    .foregroundColor(.charlestonGreen)
                                    .cornerRadius(16)
                                    .shadow(color: Color.charlestonGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.charlestonGreen, // Eton

                                    Color.alabaster  // Alabaster
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                                )
            )
            .edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .topTrailing) {
                Color.etonBlue
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)
                
                Button(action: {
                    withAnimation {
                        showGetStarted = true
                    }
                }) {
                    if showGetStarted == true {
                        Text("")
                            
                    }else{
                        Text("Skip")
                            .foregroundColor(.alabaster)
                            .padding(.horizontal, 30)
                    }
                    
                }
                .padding(.top, 0)
                .padding(.trailing, 0)
            }
        }
    }
}

import SDWebImageSwiftUI


struct OnboardingPageView: View {
    let image: String
    let title: String
    let description: String
    
    @State private var imageScale: CGFloat = 0.6
    @State private var textOpacity: Double = 0
    @State private var descriptionOffset: CGFloat = 20
    
    var body: some View {
        VStack {
            // Image with animation
            ZStack {
                if image == "ceilingHorizaontal" {
                    ZStack{
                        VStack{
                            Image("wire")
                                .resizable()
                                .scaleEffect(imageScale)
                                .frame(width: 50, height: 250)
                                .onAppear {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                                        imageScale = 1.0
                                    }
                                }
                            
                            Image(image)
                                .resizable()
                                .padding(.top, -20)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(imageScale)
                                .frame(width: 200, height: 200)
                                .onAppear {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                                        imageScale = 1.0
                                    }
                                }
                                .shadow(color:.white, radius: 4)
                            
                        }

                    }
                    
                    
                } else if image == "second"{
                    ZStack(alignment: .center){
                        
                        WebImage(url: Bundle.main.url(forResource: "stepFinal", withExtension: "gif"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 350, height: 800)
                                    .ignoresSafeArea()
                                    .padding(.bottom, -400)
                                    .ignoresSafeArea()
                    }
                    .padding(.top, 0)
                        .ignoresSafeArea()

                }
                else {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 100)
                        .frame(width: 400, height: 400)
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
            Spacer()
            // Title with animation
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.charlestonGreen)
                .padding(.top, 20)
                .shadow(radius: 20)
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
                .foregroundColor(Color.charlestonGreen.opacity(0.6))
                .padding(.horizontal, 40)
                .padding(.top, 6)
                .offset(y: descriptionOffset)
                .opacity(textOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                        descriptionOffset = 0
                        textOpacity = 1
                    }
                }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CustomPageIndicator: View {
    var currentPage: Int
    var totalPages: Int
    var activeColor: Color
    var inactiveColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { index in
                if currentPage == index {
                    Capsule()
                        .fill(activeColor)
                        .frame(width: 34, height: 8)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(inactiveColor)
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
