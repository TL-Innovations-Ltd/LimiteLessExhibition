//
//  NFCReaderView.swift
//  Limi
//
//  Created by Mac Mini on 05/04/2025.
//


import SwiftUI
import CoreNFC

struct NFCReaderView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> NFCReaderViewController {
        let controller = NFCReaderViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: NFCReaderViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NFCReaderViewControllerDelegate {
        var parent: NFCReaderView
        
        init(_ parent: NFCReaderView) {
            self.parent = parent
        }
        
        func didScanTag(tagData: String) {
            parent.scannedCode = tagData
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func didFailToScan(error: Error) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

protocol NFCReaderViewControllerDelegate: AnyObject {
    func didScanTag(tagData: String)
    func didFailToScan(error: Error)
}

class NFCReaderViewController: UIViewController, NFCTagReaderSessionDelegate {
    weak var delegate: NFCReaderViewControllerDelegate?
    private var session: NFCTagReaderSession?
    
    private var hasStartedSession = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasStartedSession {
            hasStartedSession = true
            startScanningForNFCTags()
        }
    }
    
    func startScanningForNFCTags() {
        guard NFCTagReaderSession.readingAvailable else {
            delegate?.didFailToScan(error: NFCError.notSupported)
            return
        }
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // Session is active and ready to scan
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        delegate?.didFailToScan(error: error)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                self.delegate?.didFailToScan(error: error)
                return
            }
            
            switch tag {
            case .miFare(let miFareTag):
                let tagData = miFareTag.identifier.map { String(format: "%02X", $0) }.joined()
                session.invalidate()
                DispatchQueue.main.async {
                    self.delegate?.didScanTag(tagData: tagData)
                }

                
            case .iso7816(let iso7816Tag):
                let tagData = iso7816Tag.identifier.map { String(format: "%02X", $0) }.joined()
                session.invalidate()
                DispatchQueue.main.async {
                    self.delegate?.didScanTag(tagData: tagData)
                }

            case .feliCa(let feliCaTag):
                let tagData = feliCaTag.currentIDm.map { String(format: "%02X", $0) }.joined()
                session.invalidate()
                DispatchQueue.main.async {
                    self.delegate?.didScanTag(tagData: tagData)
                }

            case .iso15693(let iso15693Tag):
                let tagData = iso15693Tag.identifier.map { String(format: "%02X", $0) }.joined()
                session.invalidate()
                DispatchQueue.main.async {
                    self.delegate?.didScanTag(tagData: tagData)
                }

            @unknown default:
                session.invalidate(errorMessage: "Unsupported tag type.")
                self.delegate?.didFailToScan(error: NFCError.unsupportedTag)
            }
        }
    }
}

enum NFCError: Error, LocalizedError {
    case notSupported
    case unsupportedTag
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "NFC scanning is not supported on this device."
        case .unsupportedTag:
            return "The scanned tag type is not supported."
        }
    }
}
