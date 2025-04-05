//
//  SuccessPopupView.swift
//  Limi
//
//  Created by Mac Mini on 05/04/2025.
//


import SwiftUI

struct SuccessPopupView: View {
    @ObservedObject var viewModel: CustomerCaptureViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Submission Successful")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
                
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.emerald)
                    .font(.system(size: 60))
                
                Text("Client information has been saved successfully!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                // QR Code
                if let qrImage = viewModel.qrCodeImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                
                // Client info summary
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Client:")
                            .font(.subheadline)
                            .bold()
                        Text(viewModel.clientCompanyInfo)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Staff:")
                            .font(.subheadline)
                            .bold()
                        Text(viewModel.staffName)
                            .font(.subheadline)
                    }
                    
                    Text("Items:")
                        .font(.subheadline)
                        .bold()
                    
                    ForEach(viewModel.itemCodes, id: \.self) { code in
                        Text("• \(code)")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Print button
                Button(action: {
                    viewModel.printQRCode()
                }) {
                    HStack {
                        Image(systemName: "printer.fill")
                        Text("Print Business Card")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.emerald)
                    .cornerRadius(12)
                }
                
                // Done button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(Color.emerald)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.emerald.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.emerald, lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
        }
    }
}