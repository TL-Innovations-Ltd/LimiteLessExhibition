import SwiftUI

struct LivingRoomView: View {
    let onBackTap: () -> Void
    let onLightTap: () -> Void
    @State private var isGraphLoaded = false
    
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
                    
                    Text("Living Room")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                .padding(.top, 50)
                
                // Room Stats
                RoomStatsView()
                
                // Usage Graph
                UsageGraphView(isLoaded: isGraphLoaded)
                
                // Devices Grid
                DevicesGridView(onLightTap: onLightTap)
                
                // Turn Off Button
                Button(action: {}) {
                    Text("Turn off all devices")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.charlestonGreen.opacity(0.8))
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
        }
        .background(Color.eton)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isGraphLoaded = true
                }
            }
        }
    }
}

struct RoomStatsView: View {
    var body: some View {
        HStack(spacing: 0) {
            RoomStatView(
                icon: "thermometer",
                value: "25",
                unit: "°C",
                label: "temperature"
            )
            
            Divider()
                .frame(height: 30)
            
            RoomStatView(
                icon: "drop.fill",
                value: "57",
                unit: "%",
                label: "humidity"
            )
            
            Divider()
                .frame(height: 30)
            
            RoomStatView(
                icon: "lightbulb.fill",
                value: "80",
                unit: "%",
                label: "lighting"
            )
        }
        .padding(.vertical, 15)
        .background(Color.cardColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct RoomStatView: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(value)
                        .font(.headline)
                    
                    Text(unit)
                        .font(.subheadline)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct UsageGraphView: View {
    let isLoaded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Usage today")
                    .font(.subheadline)
                    .foregroundColor(.emerald)
                
                Spacer()
                
                Text("25 kWh")
                    .font(.headline)
                    .foregroundColor(.emerald)
            }
            
            Text("7.5 kWh")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 5)
            
            GraphView()
                .frame(height: 60)
                .padding(.top, 5)
                .opacity(isLoaded ? 1 : 0)
            
            HStack {
                ForEach(1...6, id: \.self) { hour in
                    Text("\(hour) pm")
                        .font(.caption)
                        .foregroundColor(.emerald.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct GraphView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let points: [CGPoint] = [
                    CGPoint(x: 0, y: height * 0.7),
                    CGPoint(x: width * 0.2, y: height * 0.4),
                    CGPoint(x: width * 0.4, y: height * 0.2),
                    CGPoint(x: width * 0.6, y: height * 0.5),
                    CGPoint(x: width * 0.8, y: height * 0.3),
                    CGPoint(x: width, y: height * 0.6)
                ]
                
                path.move(to: points[0])
                for i in 1..<points.count {
                    let control1 = CGPoint(
                        x: points[i-1].x + (points[i].x - points[i-1].x) / 3,
                        y: points[i-1].y
                    )
                    let control2 = CGPoint(
                        x: points[i].x - (points[i].x - points[i-1].x) / 3,
                        y: points[i].y
                    )
                    path.addCurve(to: points[i], control1: control1, control2: control2)
                }
            }
            .stroke(Color.white, lineWidth: 2)
        }
    }
}

struct DevicesGridView: View {
    let onLightTap: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Devices")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.emerald)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)], spacing: 15) {
                DemoDeviceCard(
                    icon: "lightbulb.fill",
                    name: "Light",
                    status: "80%",
                    isActive: true,
                    onTap: onLightTap
                )
                
                DemoDeviceCard(
                    icon: "snowflake",
                    name: "AC",
                    status: "23°C",
                    isActive: false,
                    onTap: {}
                )
                
                DemoDeviceCard(
                    icon: "wifi",
                    name: "Wi-Fi",
                    status: "On",
                    isActive: true,
                    onTap: {}
                )
                
                DemoDeviceCard(
                    icon: "tv",
                    name: "Smart TV",
                    status: "Off",
                    isActive: false,
                    onTap: {}
                )
            }
        }
        .padding(.horizontal)
    }
}

struct DemoDeviceCard: View {
    let icon: String
    let name: String
    let status: String
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .gray)
                    .frame(width: 40, height: 40)
                    .background(isActive ? Color.alabaster : Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(isActive ? .black : .gray)
                
                Text(status)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 120)
            .background(Color.cardColor)
            .cornerRadius(15)
        }
    }
}

#Preview{
    LivingRoomView(onBackTap: {}, onLightTap: {})
}

