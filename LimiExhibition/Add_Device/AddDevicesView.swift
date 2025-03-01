import SwiftUI

enum ConnectionOption {
    case qrCode
    case nearby
    case manual
}

struct AddDevicesView: View {
    var onOptionSelected: (ConnectionOption) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Add your devices")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.top, 40)
                .padding(.bottom, 8)
            
            Text("Select the method of adding the device.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 16)
            
            ConnectionOptionButton(
                icon: "qrcode",
                title: "Scan QR Code",
                description: "Scan the QR code to add a device.",
                action: { onOptionSelected(.qrCode) }
            )
            
            ConnectionOptionButton(
                icon: "devices",
                title: "Nearby devices",
                description: "Find nearby devices that you can connect to.",
                action: { onOptionSelected(.nearby) }
            )
            
            ConnectionOptionButton(
                icon: "hand.tap",
                title: "Enter manually",
                description: "Find nearby devices that you can connect to.",
                action: { onOptionSelected(.manual) }
            )
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .foregroundColor(.white)
    }
}

struct ConnectionOptionButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(white: 0.15))
        .cornerRadius(12)
    }
}

