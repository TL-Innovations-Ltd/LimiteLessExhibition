import SwiftUI

class ImageRotationManager: ObservableObject {
    @Published var currentIndex = 0
    private var timer: Timer?

    let images = ["yellow", "red", "violet"]

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

struct GetStartView: View {
    @StateObject private var imageRotationManager = ImageRotationManager()
    @State private var welcomeTextOffset: CGFloat = 100
    @State private var welcomeTextOpacity: Double = 0.5
    @State private var showAlert = false
    @State private var navigateToDemo = false
    @State private var navigateToSignIn = false
    
    @State private var selectedRole: String? = nil

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.emerald, Color.etonBlue.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(0.8)
                    .ignoresSafeArea()
                    
                    VStack {
                        VStack {
                            Image(imageRotationManager.images[imageRotationManager.currentIndex])
                                .resizable()
                                .scaledToFill() // Fills width, may crop height
                                .frame(maxWidth: .infinity)
                                .clipped() // Prevents overflow
                                // Ignores safe area to cover full screen
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)
                        
                        VStack {

                            
                                
                            Text("Choose your role")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 5)
                            
                            Text("Select Mentor if you want to teach\n or Mentee if you want to learn")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.top, 0)
                            
                            HStack(spacing: 20) {
                                RoleSelectionCard(role: "Installer", isSelected: selectedRole == "Mentor") {
                                    selectedRole = "Mentor"
                                }
                                RoleSelectionCard(role: "User", isSelected: selectedRole == "Mentee") {
                                    selectedRole = "Mentee"
                                }
                            }
                            
                            Button(action: {
                                navigateToSignIn = true
                            }) {
                                Text("Get started")
                                    .font(.headline)
                                    .foregroundColor(Color.alabaster)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.emerald)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal)
                            .padding(.bottom,60)
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.5)
                        .background(Color.alabaster.ignoresSafeArea())
                        .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                        .offset(y: welcomeTextOffset)
                        .opacity(welcomeTextOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.8)) {
                                welcomeTextOffset = 0
                                welcomeTextOpacity = 2.0
                            }
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToDemo) {
                    DemoView()
                }
                .fullScreenCover(isPresented: $navigateToSignIn) {
                    LoginView() // Replace this with your actual screen
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}


struct RoleSelectionCard: View {
    let role: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: role == "Mentor" ? "person.crop.circle.fill" : "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.primary)
                
                Text(role)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(width: 140, height: 120)
            .background(isSelected ? Color.teal.opacity(0.3) : Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
}

struct GetStartView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartView()
    }
}
