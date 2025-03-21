import SwiftUI

struct LightingOnboardingView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        // Handle skip action
                        dismiss()
                    }
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Pendant lamp image
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.black)
                    .frame(width: 150, height: 150)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .offset(y: 40)
                    )
                    .overlay(
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 2, height: 60)
                            .offset(y: -80)
                    )
                    .padding(.bottom, 60)
                
                Spacer()
                
                // Text content
                VStack(spacing: 16) {
                    Text("CONTROL")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.purple.opacity(0.6))
                    
                    Text("LIGHTING")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Manage your home lighting easily\nfrom anytime & anywhere")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .padding(.bottom, 60)
                
                // Page indicator and next button
                HStack {
                    // Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color.purple.opacity(0.6) : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Next button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.mint)
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

// Preview provider for SwiftUI canvas
struct LightingOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        LightingOnboardingView()
    }
}
