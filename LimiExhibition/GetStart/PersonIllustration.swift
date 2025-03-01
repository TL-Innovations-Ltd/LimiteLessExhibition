import SwiftUI

struct PersonIllustration: View {
    let isDeaf: Bool
    
    var body: some View {
        Canvas { context, size in
            // This is a simplified illustration
            // For the deaf/hard of hearing person
            if isDeaf {
                // Head
                context.fill(
                    Path(ellipseIn: CGRect(x: 20, y: 10, width: 40, height: 40)),
                    with: .color(.black)
                )
                
                // Body
                context.fill(
                    Path(roundedRect: CGRect(x: 30, y: 50, width: 20, height: 30), cornerRadius: 5),
                    with: .color(.black)
                )
                
                // Phone
                context.fill(
                    Path(roundedRect: CGRect(x: 25, y: 60, width: 15, height: 20), cornerRadius: 3),
                    with: .color(.white)
                )
            }
            // For the sign language interpreter
            else {
                // Head
                context.fill(
                    Path(ellipseIn: CGRect(x: 20, y: 10, width: 40, height: 40)),
                    with: .color(.black)
                )
                
                // Body
                context.fill(
                    Path(roundedRect: CGRect(x: 30, y: 50, width: 20, height: 30), cornerRadius: 5),
                    with: .color(.black)
                )
                
                // Arms outstretched
                context.fill(
                    Path { path in
                        path.move(to: CGPoint(x: 30, y: 55))
                        path.addLine(to: CGPoint(x: 10, y: 50))
                        path.addLine(to: CGPoint(x: 10, y: 55))
                        path.addLine(to: CGPoint(x: 30, y: 60))
                        path.closeSubpath()
                    },
                    with: .color(.black)
                )
                
                context.fill(
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 55))
                        path.addLine(to: CGPoint(x: 70, y: 50))
                        path.addLine(to: CGPoint(x: 70, y: 55))
                        path.addLine(to: CGPoint(x: 50, y: 60))
                        path.closeSubpath()
                    },
                    with: .color(.black)
                )
            }
        }
        .frame(width: 80, height: 80)
    }
}

struct PersonIllustration_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PersonIllustration(isDeaf: true)
                .background(Color.purple)
            
            PersonIllustration(isDeaf: false)
                .background(Color.purple)
        }
    }
}

