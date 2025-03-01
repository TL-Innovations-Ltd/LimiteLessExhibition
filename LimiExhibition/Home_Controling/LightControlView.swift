import SwiftUI

struct LightControlView: View {
    let onBackTap: () -> Void
    @State private var isPowerOn = true
    @State private var brightness: Double = 80
    @State private var intensity: Double = 70
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: onBackTap) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    
                    Spacer()
                    
                    Text("Light")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding(.top, 50)
                
                // Power Toggle
                HStack {
                    Text("Power")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $isPowerOn)
                        .toggleStyle(SwitchToggleStyle(tint: Color.primaryAccent))
                }
                
                // Light Visualization
                LightVisualizationView(isPowerOn: isPowerOn, brightness: brightness)
                    .frame(height: 200)
                
                // Brightness Control
                BrightnessControl(value: $brightness)
                
                // Intensity Control
                IntensityControl(value: $intensity)
                
                // Schedule
                ScheduleView()
                
                // Usage Stats
                UsageStatsView()
            }
            .padding(.horizontal)
        }
        .background(Color.charlestonGreen)
    }
}

// MARK: - Light Visualization View
struct LightVisualizationView: View {
    let isPowerOn: Bool
    let brightness: Double
    
    var body: some View {
        ZStack {
            // Light glow effect
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .shadow(
                    color: Color.emerald.opacity(isPowerOn ? 0.5 : 0),
                    radius: isPowerOn ? brightness / 2 : 0
                )
            
            // Light bulb icon
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 100))
                .foregroundColor(Color.emerald)
                .opacity(isPowerOn ? 1 : 0.5)
                .offset(y: isPowerOn ? -30 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPowerOn)
        }
    }
}

// MARK: - Brightness Control
struct BrightnessControl: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Brightness")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Slider(value: $value, in: 0...100, step: 1)
                .tint(Color.emerald)
        }
    }
}

// MARK: - Intensity Control
struct IntensityControl: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Intensity")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "lightbulb.min")
                    .foregroundColor(.white)
                
                Slider(value: $value, in: 0...100, step: 1)
                    .tint(Color.emerald)
                
                Image(systemName: "lightbulb.max")
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Schedule View
struct ScheduleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Schedule")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
            
            VStack {
                HStack {
                    TimeSection(label: "From", time: "6:00 PM")
                    Spacer()
                    TimeSection(label: "To", time: "11:00 PM")
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: {}) {
                            Image(systemName: "trash")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
        }
    }
}

struct TimeSection: View {
    let label: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(time)
                .font(.headline)
        }
    }
}

// MARK: - Usage Stats View
struct UsageStatsView: View {
    var body: some View {
        VStack(spacing: 15) {
            StatRow(label: "Usage today", value: "0.5 kWh")
            StatRow(label: "Usage this month", value: "6 kWh")
            StatRow(label: "Total working hrs", value: "125")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.headline)
        }
    }
}

#Preview {
    LightControlView(onBackTap: {})
        .background(Color.charlestonGreen)
}
