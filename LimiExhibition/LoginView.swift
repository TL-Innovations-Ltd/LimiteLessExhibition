import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var isShowingOTPView: Bool = false
    @State private var generatedOTP: String = ""
    @State private var enteredOTP: String = ""
    @State private var isOTPVerified: Bool = false
    
    // Animation states
    @State private var welcomeTextOffset: CGFloat = 100
    @State private var welcomeTextOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.etonBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack {
                    Text("Register")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.alabaster)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(
                    Color.etonBlue.opacity(0.8)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                )
                .padding(.horizontal)
                
                VStack {
                    VStack {
                        Image("logoSplash")
                            .resizable()
                            .frame(width: 200, height: 150)
                            .padding(.bottom, 100)
                            .offset(y: welcomeTextOffset)
                            .opacity(welcomeTextOpacity)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.8)) {
                                    welcomeTextOffset = 0
                                    welcomeTextOpacity = 1.0
                                }
                            }
                        Text("Create a New Account!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.charlestonGreen)
                        Text("Join us and start your journey today.")
                            .font(.subheadline)
                            .foregroundColor(Color.charlestonGreen)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    VStack(spacing: 20) {
                        TextField("Email Address", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        generateOTP()
                    }) {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.etonBlue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $isShowingOTPView) {
                        OTPVerificationView(email: email, enteredOTP: $enteredOTP, isOTPVerified: $isOTPVerified)
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.alabaster.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding(.bottom, 0)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .fullScreenCover(isPresented: $isOTPVerified) {
            AddDevices()
        }
    }
    
    func generateOTP() {
        guard let url = URL(string: "http://localhost:3000/client/send_otp") else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = ["email": email]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Error converting parameters to JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = jsonResponse["success"] as? Bool, success {
                        DispatchQueue.main.async {
                            self.generatedOTP = jsonResponse["otp"] as? String ?? ""
                            self.isShowingOTPView = true
                            print("Generated OTP: \(self.generatedOTP)")
                        }
                    } else {
                        let errorMessage = jsonResponse["error_message"] as? String ?? "Unknown error"
                        print("Error: \(errorMessage)")
                    }
                }
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct OTPVerificationView: View {
    var email: String
    @Environment(\.presentationMode) var presentationMode  // Access presentation mode
    
    @State private var showAddDevices = false
    
    
    @EnvironmentObject var authManager: AuthManager
    
    @Binding var enteredOTP: String
    @Binding var isOTPVerified: Bool
    
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.etonBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Enter OTP")
                    .font(.title)
                    .bold()
                
                TextField("OTP", text: $enteredOTP)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Button(action: verifyOTP) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Verify")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.etonBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.alabaster.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
            // Navigation based on showAddDevices state
            if isOTPVerified {
                NavigationLink(destination: showAddDevices ? AnyView(AddDevices()) : AnyView(HomeView()), isActive: $isOTPVerified) {
                    EmptyView()
                }
            }
        }
    }
        
        
        
        func verifyOTP() {
            guard let url = URL(string: "http://localhost:3000/client/verify_otp") else {
                errorMessage = "Invalid URL"
                return
            }
            
            let parameters: [String: Any] = [
                "email": email,
                "otp": enteredOTP.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
                errorMessage = "Error creating JSON"
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            isLoading = true
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = "Request failed: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let data = data else {
                        errorMessage = "No data received"
                        return
                    }
                    
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let success = jsonResponse["success"] as? Bool, success {
                                if let dataDict = jsonResponse["data"] as? [String: Any],
                                   let token = dataDict["token"] as? String {
                                    AuthManager.shared.saveToken(token)
                                    print(dataDict)
                                    print("Received Token: \(token)") // This should now print correctly
                                    
                                    // Checking devices
                                    if let userData = dataDict["data"] as? [String: Any],
                                       let devices = userData["devices"] as? [[String: Any]] {
                                        print("suzair \(devices)")
                                        showAddDevices = !devices.isEmpty // Updated logic
                                    }
                                    
                                    
                                    
                                } else {
                                    print("Token not found in response: \(jsonResponse)")
                                }
                                
                                DispatchQueue.main.async {
                                    self.isOTPVerified = true
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                errorMessage = jsonResponse["error_message"] as? String ?? "Invalid OTP"
                            }
                        }
                    } catch {
                        errorMessage = "Failed to parse response"
                    }
                }
            }.resume()
        }
        
        
    }
    


struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
