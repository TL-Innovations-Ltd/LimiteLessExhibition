import SwiftUI

struct LightCard: View {
    let lightName: String
    @State private var isOn: Bool = false
    @State private var navigate = false

    var body: some View {
        ZStack {
            NavigationLink(destination: PWM2LEDView(hub: Hub(name: "Test Hub")), isActive: $navigate) {
                EmptyView()
            }
            .hidden()

            HStack {
                // Tap area for navigation
                VStack(alignment: .leading) {
                    Text(lightName)
                        .font(.headline)
                        .foregroundColor(.charlestonGreen)
                }
                .onTapGesture {
                    navigate = true
                }

                Spacer()

                // Fully functional toggle
                Toggle(isOn: $isOn) {
                    Text(isOn ? "On" : "Off")
                        .foregroundColor(isOn ? .green : .red)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .labelsHidden()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}
