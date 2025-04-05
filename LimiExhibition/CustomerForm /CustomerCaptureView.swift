import SwiftUI
import CoreNFC
import CoreImage.CIFilterBuiltins

struct CustomerCaptureView: View {
    @StateObject private var viewModel = CustomerCaptureViewModel()
    @State private var showingCameraView = false
    @State private var showingNFCReader = false
    @State private var showingFrontCard = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Business Card Preview Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Business Card Preview")
                            .foregroundColor(.alabaster)
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
                                    .background(Color.emerald)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Client Information")
                            .foregroundColor(.alabaster)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Staff Name field
                            TextField("Staff Name", text: $viewModel.staffName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            // Combined Client/Company field
                            TextField("Client Name / Company", text: $viewModel.clientCompanyInfo)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            // Multiple Item Codes Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Item Codes")
                                    .foregroundColor(.alabaster)

                                    .font(.headline)
                                    .padding(.bottom, 4)
                                
                                ForEach(0..<viewModel.itemCodes.count, id: \.self) { index in
                                    HStack {
                                        TextField("Item Code \(index + 1)", text: $viewModel.itemCodes[index])
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        
                                        if viewModel.itemCodes.count > 1 {
                                            Button(action: {
                                                viewModel.removeItemCode(at: index)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 22))
                                            }
                                            .padding(.leading, 8)
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.addItemCode()
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Add Another Item Code")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(Color.emerald)
                                    .padding(.vertical, 8)
                                }
                            }
                            
                            // Notes field with character count
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes (max 500 characters)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: Binding(
                                        get: { viewModel.notes },
                                        set: { viewModel.limitNotesText($0) }
                                    ))
                                    .frame(minHeight: 100)
                                    .padding(4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    if viewModel.notes.isEmpty {
                                        Text("Enter notes about the client...")
                                            .foregroundColor(.gray.opacity(0.8))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 12)
                                            .allowsHitTesting(false)
                                    }
                                }
                                
                                Text("\(viewModel.notes.count)/\(viewModel.notesCharacterLimit)")
                                    .font(.caption)
                                    .foregroundColor(
                                        viewModel.notes.count >= viewModel.notesCharacterLimit ?
                                        .red : .secondary
                                    )
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
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
                                    .fill(Color.emerald.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.emerald, lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(!NFCTagReaderSession.readingAvailable)
                        .padding(.horizontal)
                        
                        // Capture Front Card Button
                        Button(action: {
                            viewModel.captureMode = .frontCard
                            showingCameraView = true
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
                            showingCameraView = true
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
                    }
                    
                    // Submit Button
                    Button(action: {
                        viewModel.submitData()
                        // Dismiss the keyboard when the button is tapped
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Submit Data")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.canSubmit ?
                                    Color.emerald : Color.gray.opacity(0.5)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canSubmit)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                }
                .background(Color.charlestonGreen)
                .padding(.vertical)
            }
            .navigationTitle("Client Capture")
            .fullScreenCover(isPresented: $showingCameraView) {
                CameraView(
                    image: Binding(
                        get: { nil },
                        set: { newImage in
                            if let image = newImage {
                                switch viewModel.captureMode {
                                case .frontCard:
                                    viewModel.businessCardFront = image
                                case .backCard:
                                    viewModel.businessCardBack = image
                                }
                            }
                        }
                    ),
                    captureMode: viewModel.captureMode
                )
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
            .overlay(
                Group {
                    if viewModel.showSuccessPopup {
                        SuccessPopupView(
                            viewModel: viewModel,
                            isPresented: $viewModel.showSuccessPopup
                        )
                    }
                }
            )
        }
    }
}

struct CustomerCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerCaptureView()
    }
}
