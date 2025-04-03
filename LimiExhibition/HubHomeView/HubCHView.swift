//
//  ContentView.swift
//  Limi
//
//  Created by Mac Mini on 01/04/2025.
//


import SwiftUI

struct HubCHView: View {
    var body: some View {
        // A grid layout with 4 columns
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        VStack{
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...16, id: \.self) { index in
                        CardView(cardNumber: index)
                    }
                }
                .padding()
            }
        }
        .background(ElegantGradientBackgroundView())

    }
}

struct CardView: View {
    var cardNumber: Int
    
    var body: some View {
        VStack {
            Text("Channel \(cardNumber)")
                .font(.headline)
                .padding()
                .foregroundColor(.charlestonGreen)
        }
        .frame(width: (UIScreen.main.bounds.width - 60) / 4, height: 100) // Responsive width
        .background(Color.alabaster)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


#Preview {
    HubCHView()
}
