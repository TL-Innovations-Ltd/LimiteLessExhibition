//
//  AIModeView.swift
//  Limi
//
//  Created by Mac Mini on 10/05/2025.
//


import SwiftUI

struct AIModeView: View {
    @State private var isAIActivated = false
    @State private var animationAmount: CGFloat = 1
    @State private var instructionText = "Analyzing your lighting preferences..."
    @State private var showScrollView = false
    
    // Sample preset data
    let presets = [
        AIPreset(time: "7:00 AM", description: "Brightness set to 75%, RGB colors adjusted to energizing morning tones."),
        AIPreset(time: "12:00 PM", description: "Brightness set to 100%, RGB colors become vibrant and productive."),
        AIPreset(time: "3:00 PM", description: "Slight brightness reduction to 85%, RGB balanced for afternoon focus."),
        AIPreset(time: "6:00 PM", description: "Brightness reduced to 50%, RGB adjusted to warm evening tones."),
        AIPreset(time: "8:00 PM", description: "Relaxation mode with 40% brightness and calming color palette."),
        AIPreset(time: "10:00 PM", description: "Subtle night mode activated with dim RGB and low PWM for better sleep.")
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.charlestonGreen, .charlestonGreen.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Main content
            VStack(spacing: 25) {
                // Header Section
                headerSection
                
                // Preset Automation Display
                presetAutomationSection
                
                // Activation Button
                activationButton
                
                Spacer()
            }
            .padding()
            
            // Floating Instruction Panel
            floatingInstructionPanel
        }
        .onChange(of: isAIActivated) { activated in
            if activated {
                // Simulate AI reasoning with changing instruction text
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    instructionText = "Calibrating lighting patterns based on your usage..."
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    instructionText = "Optimizing energy consumption while maintaining your preferences..."
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    instructionText = "LIMI AI is now active and adapting to your environment."
                }
            } else {
                instructionText = "Analyzing your lighting preferences..."
            }
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Image("logo")
                    .resizable()
                    .frame(width: 180, height: 30)
                
                Spacer()
                
                // AI Icon
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 30))
                    .foregroundColor(isAIActivated ? Color.blue.opacity(0.8) : .gray)
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.6), lineWidth: isAIActivated ? 2 : 0)
                            .scaleEffect(animationAmount)
                            .opacity(Double(2 - animationAmount))
                            .animation(
                                Animation.easeOut(duration: 1)
                                    .repeatForever(autoreverses: false),
                                value: animationAmount
                            )
                    )
                    .onAppear {
                        if isAIActivated {
                            animationAmount = 2
                        }
                    }
            }
            
            Text("Everything is measured. Based on your previous activity, we will now apply AI automation to your settings.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.alabaster)
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
        }
    }
    
    private var presetAutomationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI-Driven Presets")
                .font(.headline)
                .foregroundColor(.alabaster.opacity(0.9))
                .padding(.leading, 5)
            
            if showScrollView {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(presets) { preset in
                            PresetCard(preset: preset, isActive: isAIActivated)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .frame(height: 300)
                .transition(.opacity)
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("AI is Processing...")
                        .foregroundColor(.alabaster.opacity(0.8))
                        .font(.subheadline)
                }
                .frame(height: 300)
                
            }
        }
        .padding(.top, 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showScrollView = true
                }
            }
        }
    }
    
    private var activationButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                isAIActivated.toggle()
                if isAIActivated {
                    animationAmount = 2
                } else {
                    animationAmount = 1
                }
            }
        }) {
            Text(isAIActivated ? "LIMI AI Active" : "Activate LIMI AI")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.alabaster)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isAIActivated ?
                              LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]), startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]), startPoint: .leading, endPoint: .trailing))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: isAIActivated ? Color.blue.opacity(0.5) : Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
        }
        .padding(.horizontal, 20)
    }
    
    private var floatingInstructionPanel: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow.opacity(0.8))
                        
                        Text("AI Processing")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.alabaster)

                        Spacer()
                        
                        // Animated dots to simulate processing
                        HStack(spacing: 3) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 5, height: 5)
                                    .opacity(isAIActivated ? 1 : 0.3)
                                    .animation(isAIActivated ?
                                               Animation.easeInOut(duration: 0.5)
                                        .repeatForever()
                                        .delay(Double(i) * 0.2) :
                                            .default,
                                               value: isAIActivated
                                    )
                            }
                        }
                    }
                    
                    Text(instructionText)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.alabaster.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.5))
                        .background(
                            VisualEffectBlur(blurStyle: .dark)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .frame(width: 250)
                .opacity(0.9)
                .padding(.bottom, 50) // 50pt from bottom
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Supporting Views and Models

struct AIPreset: Identifiable {
    let id = UUID()
    let time: String
    let description: String
}

struct PresetCard: View {
    let preset: AIPreset
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Text(preset.time)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.alabaster)
                .frame(width: 80)
            
            Rectangle()
                .fill(Color.alabaster.opacity(0.5))
                .frame(width: 1, height: 40)
            
            Text(preset.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.alabaster.opacity(0.8))
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.emerald.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color.emerald.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.eton.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// A UIViewRepresentable for blur effect
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

// Preview
struct AIModeView_Previews: PreviewProvider {
    static var previews: some View {
        AIModeView()
            .preferredColorScheme(.dark)
    }
}
