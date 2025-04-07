import SwiftUI

struct DemoDeviceControlView: View {
    @State var device: DemoDevice
    @State private var isAnimating = false
    @State private var showToast = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Device icon
                deviceIconView
            
                // Device name
                Text(device.name)
                    .font(.title)
                    .fontWeight(.bold)
            
                // Controls section
                controlsSection
            }
            .padding()
        }
        .navigationTitle("Device Control")
        .overlay(toastOverlay)
    }

    // MARK: - Subviews
    private var deviceIconView: some View {
        let iconColor: Color = device.isOn
            ? (device.type == .light ? device.color : .blue)
            : .gray
    
        let iconOpacity: Double = (device.isOn && isAnimating) ? 0.5 : 1.0
    
        return Image(systemName: device.iconName)
            .font(.system(size: 80))
            .foregroundColor(iconColor)
            .opacity(iconOpacity)
            .animation(
                device.isAIControlled
                    ? Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
                    : .default,
                value: isAnimating
            )
    }

    private var controlsSection: some View {
        VStack(spacing: 25) {
            // Power toggle
            powerToggle
        
            // Light-specific controls
            if device.type == .light {
                brightnessControl
                colorPickerControl
            }
        
            // LIMI AI Button
            aiButton
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var powerToggle: some View {
        HStack {
            Text("Power")
                .font(.headline)
        
            Spacer()
        
            Toggle("", isOn: $device.isOn)
                .labelsHidden()
                .disabled(device.isAIControlled)
        }
    }

    private var brightnessControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Brightness")
                .font(.headline)
        
            HStack {
                Image(systemName: "sun.min.fill")
                    .foregroundColor(.gray)
            
                Slider(value: $device.brightness, in: 0...100)
                    .disabled(device.isAIControlled)
            
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
            }
        
            Text("\(Int(device.brightness))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var colorPickerControl: some View {
        let colors: [Color] = [.white, .blue, .red, .green, .purple, .orange]
    
        return VStack(alignment: .leading, spacing: 10) {
            Text("Color")
                .font(.headline)
        
            HStack(spacing: 15) {
                ForEach(colors, id: \.self) { color in
                    colorCircle(for: color)
                }
            }
        }
        .disabled(device.isAIControlled)
    }

    private func colorCircle(for color: Color) -> some View {
        let isSelected = device.color == color
        let strokeColor = isSelected ? Color.blue : Color.clear
    
        return Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(strokeColor, lineWidth: 3)
            )
            .onTapGesture {
                if !device.isAIControlled {
                    device.color = color
                }
            }
    }

    private var aiButton: some View {
        Button(action: toggleAIMode) {
            HStack {
                Image(systemName: "waveform")
                Text("LIMI AI")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(device.isAIControlled ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(device.isAIControlled ? .white : .primary)
            .cornerRadius(10)
            .animation(.spring(), value: device.isAIControlled)
        }
    }

    private var toastOverlay: some View {
        Group {
            if showToast {
                VStack {
                    Spacer()
                
                    HStack {
                        Image(systemName: "waveform")
                        Text("AI adjusting environment...")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Actions
    private func toggleAIMode() {
        device.isAIControlled.toggle()
    
        if device.isAIControlled {
            isAnimating = true
            showToast = true
        
            // Simulate AI adjustments
            if device.type == .light && device.isOn {
                // Start with current settings
            }
        } else {
            isAnimating = false
            showToast = false
        }
    }
}

struct DemoDeviceControlView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DemoDeviceControlView(device: DemoDevice(
                id: "1",
                name: "Living Room Light",
                type: .light,
                isOn: true,
                brightness: 80
            ))
        }
    }
}

