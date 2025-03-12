import SwiftUI

// MARK: - AddDevices View

struct AddDevices: View {
    @State private var navigatetonBlueearbyDevices = false  // State variable to control navigation

    var body: some View {
          
        NavigationStack {
            
            
            VStack(alignment: .leading, spacing: 20) {
                // Custom Title and Subheading
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Your Devices")
                        .font(.largeTitle)
                        .font(.custom("Times New Roman", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.charlestonGreen)
                    
                    Text("Select the method of adding the device")
                        .font(.subheadline)
                        .foregroundColor(.charlestonGreen.opacity(0.8))
                }
                .padding(.top, 30)
                .padding(.bottom,40)
                // Option 1: Scan QR Code
                CardButtonView(
                    title: "Scan QR Code",
                    description: "Scan the QR code to add a device.",
                    iconName: "qrcode.viewfinder",
                    gradientColors: [Color.emerald, Color.etonBlue]) {
                        print("Scan QR Code tapped")
                    }
                
                // Option 2: Nearby Devices - Navigation to NearByDeviceView
                CardButtonView(
                                   title: "Nearby Devices",
                                   description: "Find nearby devices that you can connect to.",
                                   iconName: "wifi",
                                   gradientColors: [Color.emerald, Color.etonBlue]) {
                                       navigatetonBlueearbyDevices = true
                                   }
                // Option 3: Enter Manually
                CardButtonView(
                    title: "Enter Manually",
                    description: "Manually enter details to add a device.",
                    iconName: "keyboard",
                    gradientColors: [Color.emerald, Color.etonBlue]) {
                        print("Enter Manually tapped")
                    }
                
                Spacer()
            }
            .padding()
            .background(Color.alabaster.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true) // Hide the default navigation title
            .navigationDestination(isPresented: $navigatetonBlueearbyDevices) {
                         //   NearbyDevicesView() // Navigate to NearbyDevicesView
                        }
        }
    }
}

// MARK: - CardButtonView with Description Inside Button

struct CardButtonView: View {
    let title: String
    let description: String
    let iconName: String
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: iconName)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.8)) // Slightly faded for better UI
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(
                LinearGradient(gradient: Gradient(colors: gradientColors),
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .shadow(color: gradientColors.first?.opacity(0.5) ?? Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
        }
        .cornerRadius(5)
        .buttonStyle(PlainButtonStyle()) // Removes default button styles
    }
}

// MARK: - Preview

struct AddDevice_Previews: PreviewProvider {
    static var previews: some View {
        AddDevices()
    }
}
