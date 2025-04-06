import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum CaptureMode {
    case frontCard
    case backCard
}

struct ServerResponse: Codable {
    let success: Bool
    let data: String
}

class CustomerCaptureViewModel: ObservableObject {
    @Published var staffName = ""
    @Published var clientCompanyInfo = "" // Merged client name and company
    @Published var itemCodes: [String] = [""] // Array to store multiple item codes
    @Published var nfcTagData = ""
    @Published var notes = ""
    @Published var businessCardFront: UIImage?
    @Published var businessCardBack: UIImage?
    @Published var isSubmitted = false
    @Published var showSuccessPopup = false
    @Published var generatedLink = ""
    @Published var qrCodeImage: UIImage?
    @Published var alertItem: AlertItem?
    @Published var captureMode: CaptureMode = .frontCard
    
    // Character limit for notes
    let notesCharacterLimit = 500
    
    var canSubmit: Bool {
        !staffName.isEmpty &&
        !clientCompanyInfo.isEmpty &&
        !itemCodes.isEmpty &&
        itemCodes.allSatisfy({ !$0.isEmpty }) && // Ensure all item codes are non-empty
        businessCardFront != nil &&
        businessCardBack != nil
    }
    
    // Add a new empty item code field
    func addItemCode() {
        itemCodes.append("")
    }
    
    // Remove an item code at specific index
    func removeItemCode(at index: Int) {
        guard itemCodes.count > 1 && index < itemCodes.count else { return }
        itemCodes.remove(at: index)
    }
    
    // Function to limit notes text to 500 characters
    func limitNotesText(_ text: String) {
        if text.count <= notesCharacterLimit {
            notes = text
        } else {
            notes = String(text.prefix(notesCharacterLimit))
            // Alert user that limit has been reached
            alertItem = AlertItem(
                title: "Character Limit Reached",
                message: "Notes are limited to \(notesCharacterLimit) characters."
            )
        }
    }
    
    func submitData() {
        guard canSubmit else {
            alertItem = AlertItem(
                title: "Missing Information",
                message: "Please fill in all required fields and capture business card images."
            )
            return
        }
        
        // Convert images to base64 for sending
        guard let frontCardImageData = businessCardFront?.jpegData(compressionQuality: 0.7),
              let backCardImageData = businessCardBack?.jpegData(compressionQuality: 0.7) else {
            alertItem = AlertItem(
                title: "Image Error",
                message: "Could not process the captured images."
            )
            return
        }
        
        let base64FrontCard = "data:image/jpeg;base64," + frontCardImageData.base64EncodedString()
        let base64BackCard = "data:image/jpeg;base64," + backCardImageData.base64EncodedString()
        
        // Create request payload
        let payload: [String: Any] = [
            "staffName": staffName,
            "clientCompanyInfo": clientCompanyInfo,
            "itemCodes": itemCodes,
            "nfcData": nfcTagData,
            "notes": notes,
            "frontCardImage": base64FrontCard,
            "backCardImage": base64BackCard
        ]
        
        // Send data to backend
        NetworkService.shared.sendData(payload: payload) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let responseData):
                    if let response = responseData as? ServerResponse {
                        
                            self.generatedLink = response.data
                            self.generateQRCode(from: response.data)
                            self.isSubmitted = true
                            self.showSuccessPopup = true
                       
                        }
                    
                case .failure(let error):
                    self.alertItem = AlertItem(
                        title: "Submission Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    func generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let scale = UIScreen.main.scale
            let transform = CGAffineTransform(scaleX: 10 * scale, y: 10 * scale)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                self.qrCodeImage = UIImage(cgImage: cgImage)
            }
        }
    }
    
    func printQRCode() {
        guard let qrImage = qrCodeImage else {
            alertItem = AlertItem(
                title: "Print Error",
                message: "No QR code available to print."
            )
            return
        }
        
        // Convert the QR code image to base64 string
        guard let imageData = qrImage.pngData() else {
            alertItem = AlertItem(
                title: "Print Error",
                message: "Failed to convert QR code to image data."
            )
            return
        }
        let base64String = imageData.base64EncodedString()

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Business Card QR"
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // Create item codes HTML list
        let itemCodesHTML = itemCodes.map { "<li>\($0)</li>" }.joined()
        
        // Create business card sized HTML
        let formatter = UIMarkupTextPrintFormatter(markupText: """
        <html>
        <head>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 0;
                    padding: 0;
                    width: 3.5in;
                    height: 2in;
                }
                .card {
                    width: 100%;
                    height: 100%;
                    padding: 0.2in;
                    box-sizing: border-box;
                    display: flex;
                }
                .qr-section {
                    width: 30%;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                }
                .info-section {
                    width: 70%;
                    padding-left: 0.2in;
                }
                h1 {
                    font-size: 14pt;
                    margin: 0 0 0.1in 0;
                }
                h2 {
                    font-size: 12pt;
                    margin: 0 0 0.1in 0;
                }
                p {
                    font-size: 9pt;
                    margin: 0 0 0.05in 0;
                }
                ul {
                    margin: 0.05in 0;
                    padding-left: 0.2in;
                    font-size: 9pt;
                }
            </style>
        </head>
        <body>
            <div class="card">
                    
                <div class="info-section">
                    <h1>\(clientCompanyInfo)</h1>
                    <p>Staff: \(staffName)</p>
                    <h2>Items:</h2>
                    <ul>
                        \(itemCodesHTML)
                    </ul>
                    <p style="font-size: 8pt;">Scan QR code for more details</p>
        <img src="data:image/png;base64,\(base64String)" alt="QR Code" style="width: 100px; height: auto;" />
                            <p>Staff: \(staffName)</p>

                </div>
            </div>
        </body>
        </html>
        """)
        
        formatter.perPageContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        printController.printFormatter = formatter
        printController.printingItem = qrImage
        
        printController.present(animated: true) { (controller, completed, error) in
            if let error = error {
                self.alertItem = AlertItem(
                    title: "Print Error",
                    message: error.localizedDescription
                )
            }
        }
    }

}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
