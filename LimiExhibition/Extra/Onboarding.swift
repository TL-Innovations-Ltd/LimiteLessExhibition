//
//  Onboarding.swift
//  LimiExhibition
//
//  Created by Mac Mini on 26/02/2025.
//

import SwiftUI

struct Onboarding: View {
    var body: some View {
        ZStack {
            // Background Image

            // Dark overlay for readability
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Title
                Text("Personalize your smart home experience")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Subtitle
                Text("We know your home is unique. You may have an apartment, a three-story mansion, or an open concept home. Set up your devices to work for you in your space.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Pagination Indicators
                HStack {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .frame(width: index == 1 ? 8 : 6, height: index == 1 ? 8 : 6)
                            .foregroundColor(index == 1 ? .white : .gray)
                    }
                }
                .padding(.top, 15)
                
                // Create Account Button
                Button(action: {
                    // Button Action
                }) {
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Already a member? Log in
                HStack {
                    Text("Already a member?")
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // Log in action
                    }) {
                        Text("Log in")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 10)
                
                Spacer().frame(height: 50)
            }
        }
    }
}

struct SmartHomeView_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
