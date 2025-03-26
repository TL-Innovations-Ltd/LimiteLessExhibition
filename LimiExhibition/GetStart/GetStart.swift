//
//  GetStart 2.swift
//  Limi
//
//  Created by Mac Mini on 11/03/2025.
//


import SwiftUI
struct ElegantGradientBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.charlestonGreen,

                    Color(red: 243/255, green: 235/255, blue: 226/255)  // Alabaster
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Soft blur overlay to add depth
            VisualEffectBlur()
        }
    }
}

struct VisualEffectBlur: View {
    var body: some View {
        Color.white.opacity(0.1)
            .blur(radius: 15)
            .ignoresSafeArea()
    }
}

struct GetStart: View {
    @State private var selectedRole: Role? = nil
    @State private var isAnimating = false
    @State private var showGetStarted = false
    @State private var navigateToSignIn = false
    @State private var navigateToAddDevice = false
    @State private var isLoading = false

    enum Role {
        case deafOrHardOfHearing // Installer
        case signLanguageInterpreter // User
        case productionUser // Production User
    }

    var body: some View {
        ZStack {
            ElegantGradientBackgroundView()

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
                    .shadow(radius: 1)
                    .foregroundColor(.alabaster)  // Change the text color here

                
                VStack(spacing: 20) {
                    // Installer Role Card
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
                    .shadow(color: .alabaster , radius: 2)
                    
                    ZStack{

                        // Animated "or" text
                        Text("or")
                            .font(.custom("Amenti-back", size: 26))
                            .foregroundColor(.charlestonGreen)
                            .padding(.vertical, 4)
                            
                        Circle()
                            .fill(Color.alabaster)
                            .opacity(0.2)
                            .frame(width: 40, height: 40)

                    }
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(.spring(response: 0.5).delay(0.3), value: isAnimating)
                        
                    
                    // User Role Card
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
                    .shadow(color: .alabaster , radius: 2)

                    ZStack{

                        // Animated "or" text
                        Text("or")
                            .font(.custom("Amenti-back", size: 26))
                            .foregroundColor(.charlestonGreen)
                            .padding(.vertical, 4)
                            
                        Circle()
                            .fill(Color.alabaster)
                            .opacity(0.2)
                            .frame(width: 40, height: 40)

                    }
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(.spring(response: 0.5).delay(0.3), value: isAnimating)
                    
                    // User Role Card
                    RoleCard(
                        role: .productionUser,
                        isSelected: selectedRole == .productionUser,
                        action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedRole = .productionUser
                                showGetStarted = true
                            }
                        }
                    )
                    .shadow(color: .alabaster , radius: 2)

                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                Spacer()
                
                // Get Started Button
                GetStartedButton(isEnabled: selectedRole != nil, isVisible: showGetStarted, selectedRole: selectedRole)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
        .navigationBarBackButtonHidden(true) // Hides the default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Go back to the previous screen
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.charlestonGreen) // Change the color here
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        
        .fullScreenCover(isPresented: $navigateToAddDevice) {
            AddDeviceView()
        }
        .fullScreenCover(isPresented: $navigateToSignIn) {
            LoginView()
        }
    }
    private func createProductionUser() {
        navigateToAddDevice = true
    }
    private func createInstallerUser() {
        isLoading = true
        guard let url = URL(string: "https://suzair-backend-limi-project.vercel.app/client/installer_user") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [:] // Add any required request parameters here
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                print("API error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Parse JSON response
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let jsonResponse = jsonObject as? [String: Any] {
                    // Debugging: Print the whole response
                    print("API Response:", jsonResponse)

                    if let success = jsonResponse["success"] as? Bool, success,
                       let dataContainer = jsonResponse["data"] as? [String: Any], // First "data" object
                       let token = dataContainer["token"] as? String { // Extract token directly from "data"
                        
                        AuthManager.shared.saveToken(token)
                        print("Token saved:", token) // Debugging

                        DispatchQueue.main.async {
                            navigateToAddDevice = true
                        }
                    } else {
                        print("Invalid response format:", jsonResponse)
                    }
                } else {
                    print("Failed to cast JSON response as [String: Any]")
                }
            } catch {
                print("JSON parsing error:", error.localizedDescription)
            }
        }.resume()
    }
}


struct GetStartedButton: View {
    let isEnabled: Bool
    let isVisible: Bool
    let selectedRole: GetStart.Role?

    @State private var navigateToSignIn = false
    @State private var navigateToAddDevice = false
    @State private var isLoading = false
    @StateObject private var roleManager = UserRoleManager.shared

    var body: some View {
        Button(action: {
            switch selectedRole {
            case .deafOrHardOfHearing:
                roleManager.setRole(.installer)
                createInstallerUser()
            case .signLanguageInterpreter:
                roleManager.setRole(.user)
                navigateToSignIn = true
            case .productionUser:
                roleManager.setRole(.productionUser)
                createProductionUser()
            case .none:
                break
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Continue")
                        .font(.system(size: 16, weight: .medium))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .opacity(isEnabled ? 1 : 0)
                        .scaleEffect(isEnabled ? 1 : 0.7)
                        .animation(.spring(response: 0.3), value: isEnabled)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.black : Color.gray.opacity(0.2))
                    .animation(.easeInOut(duration: 0.2), value: isEnabled)
            )
            .foregroundColor(.white)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isVisible)
        }
        .disabled(!isEnabled || isLoading)
        .fullScreenCover(isPresented: $navigateToAddDevice) {
            AddDeviceView()
        }
        .fullScreenCover(isPresented: $navigateToSignIn) {
            LoginView()
        }
    }
    private func createProductionUser() {
        navigateToAddDevice = true // Navigate to AddDeviceView instead of sign-in
    }
    private func createInstallerUser() {
        isLoading = true
        guard let url = URL(string: "https://suzair-backend-limi-project.vercel.app/client/installer_user") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [:] // Add any required request parameters here
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                print("API error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Parse JSON response
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let jsonResponse = jsonObject as? [String: Any] {
                    // Debugging: Print the whole response
                    print("API Response:", jsonResponse)

                    if let success = jsonResponse["success"] as? Bool, success,
                       let dataContainer = jsonResponse["data"] as? [String: Any], // First "data" object
                       let token = dataContainer["token"] as? String { // Extract token directly from "data"
                        
                        AuthManager.shared.saveToken(token)
                        print("Token saved:", token) // Debugging

                        DispatchQueue.main.async {
                            navigateToAddDevice = true
                        }
                    } else {
                        print("Invalid response format:", jsonResponse)
                    }
                } else {
                    print("Failed to cast JSON response as [String: Any]")
                }
            } catch {
                print("JSON parsing error:", error.localizedDescription)
            }
        }.resume()
    }
}


struct RoleCard: View {
    let role: GetStart.Role
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                // Role illustration
                Group {
                    switch role {
                    case .deafOrHardOfHearing:
                        DeafPersonIllustration(isSelected: isSelected)
                    case .signLanguageInterpreter:
                        InterpreterIllustration(isSelected: isSelected)
                    case .productionUser:
                        ProductionIllustration(isSelected: isSelected)
                    }
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 2) {
                    Text(getRoleTitle(role))
                        .font(.system(size: 20, weight: .heavy))
                    Text(getRoleDescription(role))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.charlestonGreen)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)

                        .fill(Color.alabaster.opacity(0.8))

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
    private func getRoleTitle(_ role: GetStart.Role) -> String {
        switch role {
        case .deafOrHardOfHearing: return "Installer"
        case .signLanguageInterpreter: return "User"
        case .productionUser: return "Production User"
        }
    }
    
    private func getRoleDescription(_ role: GetStart.Role) -> String {
        switch role {
        case .deafOrHardOfHearing:
            return "Temporary access to configure your LIMI installation."
        case .signLanguageInterpreter:
            return "Personalize and transform your LIMI lighting experience."
        case .productionUser:
            return "Manage and monitor production environment settings."
        }
    }
}


#Preview {
    GetStart()
}
