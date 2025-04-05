import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum CaptureMode {
    case frontCard
    case backCard
    case customerPhoto
}

class CustomerCaptureViewModel: ObservableObject {
    @Published var staffName = ""
    @Published var itemCode = ""
    @Published var nfcTagData = ""
    @Published var capturedImage: UIImage?
    @Published var businessCardFront: UIImage?
    @Published var businessCardBack: UIImage?
    @Published var isSubmitted = false
    @Published var generatedLink = ""
    @Published var qrCodeImage: UIImage?
    @Published var alertItem: AlertItem?
    @Published var captureMode: CaptureMode = .customerPhoto
    
    var canSubmit: Bool {
        !staffName.isEmpty &&
        !itemCode.isEmpty &&
        capturedImage != nil &&
        businessCardFront != nil &&
        businessCardBack != nil
    }
    
    func submitData() {
        guard canSubmit else {
            alertItem = AlertItem(
                title: "Missing Information",
                message: "Please fill in all required fields and capture all images."
            )
            return
        }
        
        // Convert images to base64 for sending
        guard let customerImageData = capturedImage?.jpegData(compressionQuality: 0.7),
              let frontCardImageData = businessCardFront?.jpegData(compressionQuality: 0.7),
              let backCardImageData = businessCardBack?.jpegData(compressionQuality: 0.7) else {
            alertItem = AlertItem(
                title: "Image Error",
                message: "Could not process the captured images."
            )
            return
        }
        
        let base64CustomerImage = "data:image/jpeg;base64,"+customerImageData.base64EncodedString()
        let base64FrontCard = "data:image/jpeg;base64,"+frontCardImageData.base64EncodedString()
        let base64BackCard = "data:image/jpeg;base64,"+backCardImageData.base64EncodedString()
        
        // Create request payload
        let payload: [String: Any] = [
            "staffName": staffName,
            "itemCode": itemCode,
            "nfcData": nfcTagData,
            "customerImage": base64CustomerImage,
            "frontCardImage": base64FrontCard,
            "backCardImage": base64BackCard
        ]
        
        // Send data to backend
        NetworkService.shared.sendData(payload: payload) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let responseData):
                    if let responseDict = responseData as? [String: Any],
                       let link = responseDict["link"] as? String {
                        self.generatedLink = link
                        self.generateQRCode(from: link)
                        self.isSubmitted = true
                    } else {
                        self.alertItem = AlertItem(
                            title: "Response Error",
                            message: "Could not parse the server response."
                        )
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
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "QR Code for \(itemCode)"
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        let formatter = UIMarkupTextPrintFormatter(markupText: """
        <html>
        <body style="text-align: center;">
            <h1>Item: \(itemCode)</h1>
            <p>Staff: \(staffName)</p>
            <p>Link: \(generatedLink)</p>
        </body>
        </html>
        """)
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        
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
