import SwiftUI

struct DemoContentView: View {
    @State private var isDemoMode = true
    
    var body: some View {
        Group {
            if isDemoMode {
                DemoHomeView()
            } else {
                Text("Regular App Mode")
                    .font(.title)
                    .padding()
            }
        }
        .overlay(
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isDemoMode.toggle()
                    }) {
                        Text(isDemoMode ? "Exit Demo" : "Enter Demo")
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding()
                }
            }
        )
    }
}

struct DemoContentView_Previews: PreviewProvider {
    static var previews: some View {
        DemoContentView()
    }
}

