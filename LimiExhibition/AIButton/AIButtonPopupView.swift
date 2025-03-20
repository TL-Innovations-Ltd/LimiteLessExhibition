//
//  PopupView.swift
//  Limi
//
//  Created by Mac Mini on 20/03/2025.
//

import SwiftUI

struct AIButtonPopupView: View {
    @ObservedObject var storeHistory = StoreHistory()
    @Environment(\.presentationMode) var presentationMode
    let hub: Hub

    var body: some View {
        VStack {
            Text("Queue Items for \(hub.name)")
                .font(.title)
                .padding()

            List(storeHistory.queues[hub.id] ?? [], id: \.hub.id) { item in
                Text("\(item.hub.name): \(item.formattedByteArray())")
                    .onAppear {
                        print("\(item.hub.name): \(item.formattedByteArray())")
                    }
            }

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
