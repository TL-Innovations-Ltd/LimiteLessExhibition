//
//  MockupView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 28/02/2025.
//


import SwiftUI

struct MockupView: View {
    var body: some View {
        ZStack {
            // iPhone frame
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.black)
                .frame(width: 280, height: 580)
            
            // Screen
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .frame(width: 260, height: 560)
            
            // Status bar
            HStack {
                Text("9:41")
                    .font(.system(size: 12, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "wifi")
                    Image(systemName: "battery.100")
                }
                .font(.system(size: 12))
            }
            .padding(.horizontal, 20)
            .frame(width: 260)
            .offset(y: -260)
            
            // Home indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black)
                .frame(width: 100, height: 4)
                .offset(y: 270)
            
            // Content
            GetStart()
                .frame(width: 260, height: 560)
        }
    }
}

struct MockupView_Previews: PreviewProvider {
    static var previews: some View {
        MockupView()
    }
}

