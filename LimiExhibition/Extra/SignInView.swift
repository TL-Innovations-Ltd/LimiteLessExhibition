import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showRegistrationView: Bool = false // State for sheet
    
    var body: some View {
        ZStack {
            Color.etonBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with Gradient Background
                VStack {
                    Text("Sign In")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.alabaster)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(
                    Color.etonBlue.opacity(0.8)
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .bottomRight, .topRight, .bottomLeft]))
                )
                .padding(.horizontal)
                
                // Main Content
                VStack {
                    // Welcome Text
                    VStack {
                        Text("Welcome Back To LIMI!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.charlestonGreen)
                        Text("To keep connected with us please login with your personal info")
                            .font(.subheadline)
                            .foregroundColor(Color.charlestonGreen)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Input Fields
                    VStack(spacing: 15) {
                        TextField("Email Address", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Remember Me & Forgot Password
                    HStack {
                        Button(action: {
                            rememberMe.toggle()
                        }) {
                            HStack {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color.charlestonGreen)
                                Text("Remember me")
                                    .foregroundColor(Color.charlestonGreen)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        Button("Forgot Password?") {}
                            .foregroundColor(.etonBlue)
                    }
                    .padding(.horizontal)
                    
                    // Sign In Button
                    Button(action: {
                        loginUser()
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.etonBlue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Login Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    // OR CONTINUE WITH
                    Text("OR CONTINUE WITH")
                        .foregroundColor(.charlestonGreen)
                        .padding(.top)
                    
                    // Social Login Buttons
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            HStack {
                                Image("facebook")
                                Text("Sign in with Facebook")
                                    .foregroundColor(Color.charlestonGreen).padding(5)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image("google")
                                Text("Sign in with Google")
                                    .foregroundColor(Color.charlestonGreen).padding(5)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Register Button
                    Button(action: {
                        showRegistrationView = true // Toggle the state
                    }) {
                        Text("Don't have an account? Register")
                            .font(.subheadline)
                            .foregroundColor(.etonBlue)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.alabaster.opacity(0.8))
                .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                .padding(.bottom,0)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .sheet(isPresented: $showRegistrationView) {
            LoginView() // Present RegistrationView as a sheet
        }
    }
    
    func loginUser() {
        guard let url = URL(string: "https://delivering-true-territory-connection.trycloudflare.com/admin/login") else {
            return
        }

        let body: [String: Any] = ["email": email, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let data = data else {
                    alertMessage = "No data received"
                    showAlert = true
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let success = jsonResponse["success"] as? Bool, success {
                            alertMessage = "Login Successful!"
                        } else {
                            alertMessage = jsonResponse["message"] as? String ?? "Login failed"
                        }
                    } else {
                        alertMessage = "Invalid response format"
                    }
                } catch {
                    alertMessage = "Failed to decode response"
                }
                showAlert = true
            }
        }.resume()
    }
}

// Custom RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
