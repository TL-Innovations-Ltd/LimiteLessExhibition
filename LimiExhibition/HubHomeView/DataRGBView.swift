//
//  DataRGBView.swift
//  LimiExhibition
//
//  Created by Mac Mini on 04/03/2025.
//

import SwiftUI

struct DataRGBView: View {
    @State private var selectedColor: Color = .emerald
    @State private var showingColorPicker = false
    @State private var selectedMode: ColorMode = .solid
    
    enum ColorMode: String, CaseIterable, Identifiable {
        case solid = "Solid"
        case rainbow = "Rainbow"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("1 Data RGB Controller")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.charlestonGreen)
                .padding(.top)
            
            // Mode Selection
            Picker("Mode", selection: $selectedMode) {
                ForEach(ColorMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedMode == .solid {
                // Color Display
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedColor)
                    .frame(height: 120)
                    .padding(.horizontal)
                    .shadow(color: selectedColor.opacity(0.3), radius: 10, x: 0, y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .onTapGesture {
                        showingColorPicker = true
                    }
                
                // Color Presets
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                    ColorPresetButton(color: .red, selectedColor: $selectedColor)
                    ColorPresetButton(color: .orange, selectedColor: $selectedColor)
                    ColorPresetButton(color: .yellow, selectedColor: $selectedColor)
                    ColorPresetButton(color: .green, selectedColor: $selectedColor)
                    ColorPresetButton(color: .blue, selectedColor: $selectedColor)
                    ColorPresetButton(color: .purple, selectedColor: $selectedColor)
                    ColorPresetButton(color: .pink, selectedColor: $selectedColor)
                    ColorPresetButton(color: .white, selectedColor: $selectedColor)
                }
                .padding()
            } else {
                // Rainbow Mode
                RainbowView()
                    .frame(height: 120)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
                
                // Rainbow Speed Control
                VStack(alignment: .leading) {
                    Text("Rainbow Speed")
                        .font(.headline)
                        .foregroundColor(.charlestonGreen)
                    
                    HStack {
                        Image(systemName: "tortoise")
                            .foregroundColor(.gray)
                        
                        Slider(value: .constant(0.5), in: 0...1)
                            .accentColor(.emerald)
                        
                        Image(systemName: "hare")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.alabaster)
        .cornerRadius(16)
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerView(selectedColor: $selectedColor)
        }
    }
}

struct ColorPresetButton: View {
    let color: Color
    @Binding var selectedColor: Color
    
    var body: some View {
        Button(action: {
            selectedColor = color
        }) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
                .overlay(
                    Circle()
                        .stroke(selectedColor == color ? Color.emerald : Color.clear, lineWidth: 3)
                )
        }
    }
}

struct RainbowView: View {
    @State private var animationOffset: CGFloat = 0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red]
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: -animationOffset * geometry.size.width)
            .frame(width: geometry.size.width * 2)
            .onAppear {
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                    animationOffset = 1
                }
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Select Color", selection: $selectedColor)
                    .padding()
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedColor)
                    .frame(height: 100)
                    .padding()
                    .shadow(color: selectedColor.opacity(0.3), radius: 10, x: 0, y: 0)
                
                Spacer()
            }
            .navigationTitle("Color Picker")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
#Preview {
    DataRGBView()
}
