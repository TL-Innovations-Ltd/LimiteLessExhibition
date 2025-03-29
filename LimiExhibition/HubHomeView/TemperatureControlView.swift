//
//  TemperatureControlView.swift
//  Limi
//
//  Created by Mac Mini on 29/03/2025.
//


import SwiftUI

struct TemperatureControlView: View {
    @State private var temperature: Double = 50.0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Temperature Control")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(Int(temperature))°")
                .font(.system(size: 48, weight: .medium, design: .rounded))
                .foregroundColor(temperatureColor)
            
            CurvedSlider(value: $temperature, in: 0...100, step: 1)
                .frame(width: 120 , height: 80)
            
            HStack(spacing: 40) {
                VStack {
                    Image(systemName: "thermometer.snowflake")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    Text("Cold")
                        .font(.caption)
                }
                
                VStack {
                    Image(systemName: "thermometer.sun")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    Text("Warm")
                        .font(.caption)
                }
            }
            .padding(.top, 20)
        }
        .padding(30)
        .background(Color(.systemBackground))
    }
    
    // Color that changes based on temperature
    var temperatureColor: Color {
        let normalized = temperature / 100.0
        
        if normalized < 0.33 {
            return .blue
        } else if normalized < 0.66 {
            return .primary
        } else {
            return .orange
        }
    }
}

struct TemperatureControlView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TemperatureControlView()
                .preferredColorScheme(.light)
            
            TemperatureControlView()
                .preferredColorScheme(.dark)
        }
    }
}

