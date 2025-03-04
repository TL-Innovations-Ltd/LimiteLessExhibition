import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    private let totalPages = 4 // Now 4 onboarding screens
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    imageName: "red",
                    title: "Add Smart Service to Your Home",
                    description: "Enhance convenience and comfort effortlessly."
                )
                .tag(0)
                
                OnboardingPageView(
                    imageName: "violet",
                    title: "Add Smart Service to Your Home",
                    description: "Enhance convenience and comfort effortlessly."
                )
                .tag(1)
                
                OnboardingPageView(
                    imageName: "yellow",
                    title: "Experience the Ultimate in Home Control",
                    description: "Transform your home into a smart sanctuary."
                )
                .tag(2)
                
                // Last view is GetStartView()
                GetStart()
                    .tag(3)
            }
            .ignoresSafeArea()
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
            
            if currentPage < totalPages - 1 { // Show indicator if not on last page
                CustomPageIndicator(currentPage: currentPage, totalPages: totalPages)
            }

            if currentPage < totalPages - 1 { // Show buttons only if not last page
                HStack {
                    Button("Skip") {
                        // Navigate to main app
                    }
                    .foregroundColor(.charlestonGreen)

                    Spacer()

                    Button(action: {
                        currentPage += 1
                    }) {
                        Text("Next")
                            .frame(width: 120)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .background(Color.alabaster)
        .ignoresSafeArea()
    }
}

// Custom Page Indicator (Dot changes to Line for Active Page)
struct CustomPageIndicator: View {
    var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                if currentPage == index {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: 20, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
        }
        .padding(.bottom, 10)
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack {
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 370)
                .cornerRadius(20)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
}



struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
