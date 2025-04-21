import SwiftUI

// MARK: - MVVM Architecture



// MARK: - Main View
struct HomeView: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("demoEmail") var demoEmail: String = "umer.asif@terralumen.co.uk"
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    @ObservedObject var sharedDevice = SharedDevice.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                BackgroundView(shimmerAnimation: $viewModel.shimmerAnimation)
                
                // MARK: - Main Content
                VStack(spacing: 0) {
                    // MARK: - Header
                    HeaderView(isSidebarOpen: $viewModel.isSidebarOpen)
                        .offset(y: viewModel.headerOffset)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: viewModel.headerOffset)
                        .ignoresSafeArea()
                    
                    // MARK: - Search Bar
                    SearchBarView(
                        searchText: $viewModel.searchText,
                        searchFieldFocused: $viewModel.searchFieldFocused,
                        showARScan: $viewModel.showARScan,
                        isLoaded: $viewModel.isLoaded
                    )
                    
                    // MARK: - Spaces List
                    SpacesListView(
                        demoEmail: demoEmail,
                        isLoaded: $viewModel.isLoaded,
                        isNavigatingToAddDevice: $viewModel.isNavigatingToAddDevice,
                        bluetoothManager: bluetoothManager
                    )
                    
                    Spacer()
                }
                
                // MARK: - Sidebar
                EnhancedSidebarView(isSidebarOpen: $viewModel.isSidebarOpen)
                
                // MARK: - Floating Button
                FloatingButtonView(
                    isNavigating: $viewModel.isNavigatingToAddDevice,
                    isLoaded: $viewModel.isLoaded,
                    demoEmail: demoEmail,
                    bluetoothManager: bluetoothManager
                )
                
                Spacer()
            }
            
            // MARK: - AR Scan View
            .fullScreenCover(isPresented: $viewModel.showARScan) {
                ARRoomPlanContentView()
            }
            .onAppear {
                viewModel.setupInitialState()
            }
            // MARK: - Bottom Navigation
            .overlay(
                EnhancedBottomNavigationView(
                    showARScan: $viewModel.showARScan,
                    showCustomer: $viewModel.showCustomer,
                    showGrouping: $viewModel.showGrouping,
                    showWebView: $viewModel.showWebView,
                    selectedTab: $viewModel.selectedTab,
                    isLoaded: $viewModel.isLoaded
                ),
                alignment: .bottom
            )
        }
    }
}













// MARK: - Custom Shape for Rounded Corners
struct RoundedCornerShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Enhanced Sidebar with Improved Animation
struct EnhancedSidebarView: View {
    @Binding var isSidebarOpen: Bool
    @State private var menuItems = [
        ("house.fill", "Home"),
        ("gear", "Settings"),
        ("person.fill", "Profile"),
        ("questionmark.circle", "Help"),
        ("info.circle", "About")
    ]
    @State private var selectedItem = "Home"
    @State private var animateBackground = false
    @State private var showGetStartScreen = false // State variable to control the presentation
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @AppStorage("demoEmail") var demoEmail: String = "umer.asif@terralumen.co.uk"

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced dimmed background with blur
                if isSidebarOpen {
                    Color.black.opacity(0.3)
                        .blur(radius: 0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isSidebarOpen = false
                            }
                        }
                        // Animation: Fade in/out background
                        .animation(.easeOut(duration: 0.2), value: isSidebarOpen)
                }

                HStack(spacing: 0) {
                    // Enhanced sidebar content
                    ZStack {
                        // Animated background
                        LinearGradient(
                            gradient: Gradient(colors: [Color.alabaster, Color.white.opacity(0.95)]),
                            startPoint: animateBackground ? .topLeading : .bottomTrailing,
                            endPoint: animateBackground ? .bottomTrailing : .topLeading
                        )
                        .onAppear {
                            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                                animateBackground.toggle()
                            }
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 0) {
                            // Enhanced user profile section
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            isSidebarOpen.toggle()
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.black.opacity(0.05))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "xmark")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.charlestonGreen)
                                        }
                                    }
                                    .padding(.trailing, 20)
                                    .padding(.top, 20)
                                }
                                
                                // Enhanced user avatar and info
                                HStack(spacing: 15) {
                                    // Avatar with gradient and animation
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.etonBlue, Color.etonBlue.opacity(0.7)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                            .shadow(color: Color.etonBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                                        
                                        // Animated ring
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                            .frame(width: 70, height: 70)
                                            .scaleEffect(animateBackground ? 1.1 : 0.9)
                                            .opacity(animateBackground ? 0.7 : 0.3)
                                            .animation(
                                                Animation.easeInOut(duration: 2)
                                                    .repeatForever(autoreverses: true),
                                                value: animateBackground
                                            )
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Welcome")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Text("User")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.charlestonGreen)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            .padding(.bottom, 30)
                            
                            // Enhanced menu items with staggered animation
                            ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                                Button(action: {
                                    withAnimation {
                                        selectedItem = item.1
                                        
                                        // Haptic feedback
                                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                                        impactMed.impactOccurred()
                                    }
                                }) {
                                    HStack(spacing: 15) {
                                        // Icon with background for selected item
                                        ZStack {
                                            Circle()
                                                .fill(selectedItem == item.1 ? Color.etonBlue.opacity(0.2) : Color.clear)
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: item.0)
                                                .font(.system(size: 18))
                                                .foregroundColor(selectedItem == item.1 ? Color.etonBlue : .charlestonGreen.opacity(0.7))
                                        }
                                        
                                        Text(item.1)
                                            .font(.headline)
                                            .foregroundColor(selectedItem == item.1 ? Color.etonBlue : .charlestonGreen.opacity(0.7))
                                        
                                        Spacer()
                                        
                                        if selectedItem == item.1 {
                                            Circle()
                                                .fill(Color.etonBlue)
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    // Enhanced animation: Highlight on selection
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedItem == item.1 ? Color.etonBlue.opacity(0.1) : Color.clear)
                                            .padding(.horizontal, 10)
                                    )
                                }
                                // Enhanced animation: Staggered slide-in from left with spring
                                .offset(x: isSidebarOpen ? 0 : -50)
                                .opacity(isSidebarOpen ? 1 : 0)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(isSidebarOpen ? Double(index) * 0.05 : 0),
                                    value: isSidebarOpen
                                )
                            }
                            
                            
                            
                            // Enhanced logout button with animation
                            HStack {
                                Spacer() // Pushes the button to the center

                                Button(action: {
                                    // Logout action
                                    AuthManager.shared.clearToken()
                                    showGetStartScreen = true // Set state variable to true
                                    BluetoothManager.shared.disconnectAllDevices() // Disconnect all devices
                                    hasCompletedOnboarding = false
                                    hasLaunchedBefore = false
                                    demoEmail = ""  // Set demoEmail to an empty string (null equivalent)


                                }) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red.opacity(0.1))
                                                .frame(width: 36, height: 36)

                                            Image(systemName: "arrow.left.square.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.red.opacity(0.8))
                                        }

                                        Text("Logout")
                                            .font(.headline)
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                }
                                .padding(.bottom, 30)
                                // Enhanced animation: Fade in/out with scale
                                .opacity(isSidebarOpen ? 1 : 0)
                                .scaleEffect(isSidebarOpen ? 1 : 0.9)
                                .animation(.easeIn.delay(isSidebarOpen ? 0.3 : 0), value: isSidebarOpen)

                                Spacer() // Pushes the button to the center
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.7)
                    // Enhanced animation: Slide in/out with spring physics and shadow
                    .offset(x: isSidebarOpen ? 0 : -geometry.size.width * 0.7)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSidebarOpen)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 5, y: 0)

                    Spacer()
                }
            }
            .frame(width: geometry.size.width * 0.7)
            .cornerRadius(20) // Apply rounded corners
            .clipShape(RoundedRectangle(cornerRadius: 20)) // Clip shape to avoid overflow
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 5, y: 0)
            .fullScreenCover(isPresented: $showGetStartScreen) {
                GetStart() // Replace with your GetStart screen view
            }
        }
    }
}


// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
