import SwiftUI

struct ControlPanelView: View {
    let onRoomTap: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HeaderViewHome(title: "Control Panel")
                
                // Temperature Section
                HStack(spacing: 30) {
                    WeatherInfoView(
                        icon: "cloud.bolt.fill",
                        value: "19°C",
                        label: "Temp Outside"
                    )
                    
                    WeatherInfoView(
                        icon: "thermometer",
                        value: "25°C",
                        label: "Temp Indoor"
                    )
                }
                
                // Power Usage Section
                HStack(spacing: 15) {
                    PowerUsageView(
                        value: "29,5",
                        unit: "kWh",
                        label: "Power usage today",
                        icon: "bolt.circle.fill"
                    )
                    
                    PowerUsageView(
                        value: "303",
                        unit: "kWh",
                        label: "Power usage this month",
                        icon: "arrow.clockwise.circle.fill"
                    )
                }
                
                // Scenes Section
                SectionHeaderView(title: "Scenes")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                    SceneButton(icon: "house.fill", label: "Home", isActive: true)
                    SceneButton(icon: "door.left.hand.open", label: "Away", isActive: false)
                    SceneButton(icon: "moon.fill", label: "Sleep", isActive: false)
                    SceneButton(icon: "alarm", label: "Get up", isActive: false)
                }
                .padding(.horizontal)
                
                // Rooms Section
                SectionHeaderView(title: "Rooms")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                    RoomCard(
                        icon: "sofa.fill",
                        name: "Living Room",
                        devices: "4 Devices",
                        color: .primaryAccent,
                        action: onRoomTap
                    )
                    
                    RoomCard(
                        icon: "bed.double.fill",
                        name: "Bedroom",
                        devices: "3 Devices",
                        color: .charlestonGreen,
                        action: {}
                    )
                }
                .padding(.horizontal)
            }
            .padding(.top, 50)
        }
        .background(Color.charlestonGreen)
        .padding(0)
    }
}

// MARK: - Helper Views
struct HeaderViewHome: View {
    let title: String
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }
}

struct WeatherInfoView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(value)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PowerUsageView: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardColor)
        .cornerRadius(15)
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct SceneButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(isActive ? Color.emerald : Color.white.opacity(0.1))
                .cornerRadius(12)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct RoomCard: View {
    let icon: String
    let name: String
    let devices: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(devices)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 150)
            .background(Color.cardColor)
            .cornerRadius(15)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ControlPanelView(onRoomTap: {})
}
