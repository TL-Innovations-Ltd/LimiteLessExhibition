import SwiftUI

struct DeviceSearchView: View {
    @State private var isAnimating = false
    
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.emerald.opacity(0.8), Color.eton]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Search Bar with Scan Button
                
                // Find Nearby Device Button
                Button(action: {
                    print("Finding Nearby Devices...")
                }) {
                    Text("Find Nearby Device")
                        .foregroundColor(.charlestonGreen)
                        
                        .shadow(radius: 5)
                }
                
                
                Spacer()
                    .frame(width: nil, height: 100.0)
                
                    
                Text("Searching for Cel-Fi devices...")
                    .foregroundColor(Color.charlestonGreen)
                    .font(.headline)
                    .padding(.bottom, 60)
                
                ZStack {
                    // Pulsating circles
                    ForEach(0..<4, id: \.self) { index in
                                        Circle()
                            .stroke(Color.alabaster.opacity(0.3), lineWidth: 2)
                                            .frame(width: 200, height: 200)
                                            .scaleEffect(isAnimating ? 1.8 : 0.8)
                                            .opacity(isAnimating ? 0 : 1)
                                            .animation(
                                                Animation.easeInOut(duration: 1.5)
                                                    .repeatForever()
                                                    .delay(Double(index) * 0.6),
                                                value: isAnimating
                                            )
                                    }
                    
                    // Bluetooth Icon Button
                    Button(action: {
                        print("Bluetooth Searching...")
                    }) {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .resizable()
                            .foregroundStyle(Color.charlestonGreen)
                            .frame(width: 60, height: 40)
                            .padding()
                            .background(Color.alabaster)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                }
                
                Spacer()
                
                // Install Guide Button
                Button(action: {
                    print("Connect Device")
                }) {
                    Text("Connect Device")
                        .foregroundColor(.charlestonGreen)
                        .font(.subheadline)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct DeviceSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceSearchView()
    }
}
