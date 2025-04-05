import SwiftUI
import CoreNFC
import CoreImage.CIFilterBuiltins

struct CustomerCaptureView: View {
    @StateObject private var viewModel = CustomerCaptureViewModel()
    @State private var showingImagePicker = false
    @State private var showingNFCReader = false
    @State private var showingQRCode = false
    @State private var showingFrontCard = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Business Card Preview Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Business Card Preview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(radius: 5)
                                .frame(height: 220)
                            
                            if showingFrontCard {
                                // Front Card
                                if let frontImage = viewModel.businessCardFront {
                                    Image(uiImage: frontImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .padding(10)
                                } else {
                                    VStack {
                                        Image(systemName: "creditcard")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("Front Card Preview")
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                // Back Card
                                if let backImage = viewModel.businessCardBack {
                                    Image(uiImage: backImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .padding(10)
                                } else {
                                    VStack {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("Back Card Preview")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .frame(height: 220)
                        .padding(.horizontal)
                        
                        // Toggle between front and back
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showingFrontCard.toggle()
                                }
                            }) {
                                Text(showingFrontCard ? "Show Back" : "Show Front")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Customer Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            TextField("Staff Name", text: $viewModel.staffName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            TextField("Item Code", text: $viewModel.itemCode)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Enhanced Action Buttons
                    VStack(spacing: 16) {
                        // NFC Scan Button
                        Button(action: {
                            showingNFCReader = true
                        }) {
                            HStack {
                                Image(systemName: "wave.3.right.circle.fill")
                                    .font(.system(size: 24))
                                
                                VStack(alignment: .leading) {
                                    Text("Scan NFC Tag")
                                        .font(.headline)
                                    
                                    if !viewModel.nfcTagData.isEmpty {
                                        Text("Tag: \(viewModel.nfcTagData)")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    } else {
                                        Text("Tap to scan business card tag")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(!NFCTagReaderSession.readingAvailable)
                        .padding(.horizontal)
                        
                        // Capture Front Card Button
                        Button(action: {
                            viewModel.captureMode = .frontCard
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.purple)
                                
                                VStack(alignment: .leading) {
                                    Text("Capture Front Card")
                                        .font(.headline)
                                    
                                    Text("Take a photo of the business card front")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.purple.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.purple, lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal)
                        
                        // Capture Back Card Button
                        Button(action: {
                            viewModel.captureMode = .backCard
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading) {
                                    Text("Capture Back Card")
                                        .font(.headline)
                                    
                                    Text("Take a photo of the business card back")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange, lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal)
                        
                        // Capture Customer Photo Button
                        Button(action: {
                            viewModel.captureMode = .customerPhoto
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.rectangle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading) {
                                    Text("Capture Customer Photo")
                                        .font(.headline)
                                    
                                    Text("Take a photo of the customer")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green, lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Customer Photo Preview
                    if let image = viewModel.capturedImage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Customer Photo")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Submit Button
                    Button(action: {
                        viewModel.submitData()
                    }) {
                        Text("Submit Data")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.canSubmit ?
                                    Color.blue : Color.gray.opacity(0.5)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSubmit)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // QR Code Section
                    if viewModel.isSubmitted {
                        VStack(alignment: .center, spacing: 16) {
                            Text("Generated Link & QR Code")
                                .font(.headline)
                            
                            Text(viewModel.generatedLink)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if let qrImage = viewModel.qrCodeImage {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                            }
                            
                            Button(action: {
                                viewModel.printQRCode()
                            }) {
                                HStack {
                                    Image(systemName: "printer.fill")
                                    Text("Print QR Code")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Customer Capture")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: Binding(
                    get: { nil },
                    set: { newImage in
                        if let image = newImage {
                            switch viewModel.captureMode {
                            case .frontCard:
                                viewModel.businessCardFront = image
                            case .backCard:
                                viewModel.businessCardBack = image
                            case .customerPhoto:
                                viewModel.capturedImage = image
                            }
                        }
                    }
                ))
            }
            .sheet(isPresented: $showingNFCReader) {
                NFCReaderView(scannedCode: $viewModel.nfcTagData)
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct CustomerCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerCaptureView()
    }
}
