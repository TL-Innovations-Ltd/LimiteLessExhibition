import SwiftUI

struct WhatIsLimi: View {
    // Add a navigation stack to enable navigation
    @State private var navigateToHomeView = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("What is Limi?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Text("Limi is your smart light management and automation assistant!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                
            }
            .navigationBarItems(leading: Button(action: {
                navigateToHomeView = true

                // Action for back button
                // This will pop the current view and return to the previous one (HomeView)
                // If the previous view is HomeView, it'll go back automatically
                // If it's within a NavigationStack, this should work as expected
                // Alternatively, you could use `dismiss()` if you use a modal presentation
                // Example: dismissing for fullScreenCover
                // self.presentationMode.wrappedValue.dismiss() if inside fullScreenCover
            }) {
                HStack {
                    Image(systemName: "arrow.left")

                }
                .foregroundColor(.charlestonGreen)
            })
            .fullScreenCover(isPresented: $navigateToHomeView) {
                HomeView() // Replace this with your actual screen
            }
        }
    }
}

#Preview {
    WhatIsLimi()
}
