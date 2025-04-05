//
//  CameraView.swift
//  Limi
//
//  Created by Mac Mini on 05/04/2025.
//


import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var captureMode: CaptureMode
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        controller.captureMode = captureMode
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func didCaptureImage(_ image: UIImage) {
            parent.image = image
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func didCancel() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
    func didCancel()
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    weak var delegate: CameraViewControllerDelegate?
    var captureMode: CaptureMode = .frontCard
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var frameView: UIView?
    
    // Business card standard aspect ratio is 3.5:2 (1.75:1)
    private let businessCardAspectRatio: CGFloat = 1.75
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo // Use photo preset for higher quality
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            showAlert(message: "Unable to access camera")
            return
        }
        
        // Configure camera for optimal business card capture
        do {
            try backCamera.lockForConfiguration()
            if backCamera.isAutoFocusRangeRestrictionSupported {
                backCamera.autoFocusRangeRestriction = .near // Better for close-up shots
            }
            if backCamera.isFocusModeSupported(.continuousAutoFocus) {
                backCamera.focusMode = .continuousAutoFocus
            }
            backCamera.unlockForConfiguration()
        } catch {
            print("Error configuring camera: \(error.localizedDescription)")
        }
        
        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            photoOutput.isHighResolutionCaptureEnabled = true
            if captureSession?.canAddOutput(photoOutput) == true {
                captureSession?.addOutput(photoOutput)
            }
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
    }
    
    private func setupUI() {
        // Add video preview layer
        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
        }
        
        // Calculate optimal business card frame size
        // Use 80% of screen width and maintain business card aspect ratio
        let frameWidth = view.bounds.width * 0.8
        let frameHeight = frameWidth / businessCardAspectRatio
        
        let frameX = (view.bounds.width - frameWidth) / 2
        let frameY = (view.bounds.height - frameHeight) / 2
        
        frameView = UIView(frame: CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight))
        frameView?.layer.borderColor = UIColor.white.cgColor
        frameView?.layer.borderWidth = 2.0
        frameView?.backgroundColor = UIColor.clear
        
        // Add semi-transparent overlay outside the frame
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(overlayView)
        
        // Create mask to make the frame area transparent
        let path = UIBezierPath(rect: view.bounds)
        if let frameView = frameView {
            path.append(UIBezierPath(rect: frameView.frame).reversing())
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        // Add corner markers
        let cornerSize: CGFloat = 20
        let cornerWidth: CGFloat = 3
        let corners = [
            createCorner(at: .topLeft, size: cornerSize, width: cornerWidth),
            createCorner(at: .topRight, size: cornerSize, width: cornerWidth),
            createCorner(at: .bottomLeft, size: cornerSize, width: cornerWidth),
            createCorner(at: .bottomRight, size: cornerSize, width: cornerWidth)
        ]
        
        if let frameView = frameView {
            view.addSubview(frameView)
            for corner in corners {
                frameView.addSubview(corner)
            }
        }
        
        // Add guide text
        let guideLabel = UILabel()
        guideLabel.text = captureMode == .frontCard ? "Align front of business card within frame" : "Align back of business card within frame"
        guideLabel.textColor = .white
        guideLabel.textAlignment = .center
        guideLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        guideLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        guideLabel.layer.cornerRadius = 8
        guideLabel.clipsToBounds = true
        guideLabel.sizeToFit()
        guideLabel.frame = CGRect(
            x: (view.bounds.width - guideLabel.bounds.width - 20) / 2,
            y: frameY - 50,
            width: guideLabel.bounds.width + 20,
            height: guideLabel.bounds.height + 10
        )
        view.addSubview(guideLabel)
        
        // Add capture button
        let captureButton = UIButton(type: .system)
        captureButton.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        captureButton.tintColor = .white
        captureButton.contentVerticalAlignment = .fill
        captureButton.contentHorizontalAlignment = .fill
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Add cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.addTarget(self, action: #selector(cancelCapture), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add flash toggle button
        let flashButton = UIButton(type: .system)
        flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        flashButton.tintColor = .white
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flashButton)
        
        NSLayoutConstraint.activate([
            flashButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flashButton.widthAnchor.constraint(equalToConstant: 40),
            flashButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createCorner(at position: UIRectCorner, size: CGFloat, width: CGFloat) -> UIView {
        let corner = UIView()
        corner.backgroundColor = .clear
        
        let horizontalLayer = CALayer()
        horizontalLayer.backgroundColor = UIColor.white.cgColor
        
        let verticalLayer = CALayer()
        verticalLayer.backgroundColor = UIColor.white.cgColor
        
        switch position {
        case .topLeft:
            corner.frame = CGRect(x: 0, y: 0, width: size, height: size)
            horizontalLayer.frame = CGRect(x: 0, y: 0, width: size, height: width)
            verticalLayer.frame = CGRect(x: 0, y: 0, width: width, height: size)
        case .topRight:
            corner.frame = CGRect(x: frameView!.bounds.width - size, y: 0, width: size, height: size)
            horizontalLayer.frame = CGRect(x: 0, y: 0, width: size, height: width)
            verticalLayer.frame = CGRect(x: size - width, y: 0, width: width, height: size)
        case .bottomLeft:
            corner.frame = CGRect(x: 0, y: frameView!.bounds.height - size, width: size, height: size)
            horizontalLayer.frame = CGRect(x: 0, y: size - width, width: size, height: width)
            verticalLayer.frame = CGRect(x: 0, y: 0, width: width, height: size)
        case .bottomRight:
            corner.frame = CGRect(x: frameView!.bounds.width - size, y: frameView!.bounds.height - size, width: size, height: size)
            horizontalLayer.frame = CGRect(x: 0, y: size - width, width: size, height: width)
            verticalLayer.frame = CGRect(x: size - width, y: 0, width: width, height: size)
        default:
            break
        }
        
        corner.layer.addSublayer(horizontalLayer)
        corner.layer.addSublayer(verticalLayer)
        
        return corner
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopSession() {
        captureSession?.stopRunning()
    }
    
    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        
        // Enable flash if available
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            settings.flashMode = .auto
        }
        
        // Enable high resolution capture
        settings.isHighResolutionPhotoEnabled = true
        
        // Add visual feedback for capture
        UIView.animate(withDuration: 0.1, animations: {
            self.view.alpha = 0.0
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.view.alpha = 1.0
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func cancelCapture() {
        delegate?.didCancel()
    }
    
    @objc private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error.localizedDescription)")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            showAlert(message: "Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            showAlert(message: "Unable to create image from photo")
            return
        }
        
        // Crop image to frame with precise business card dimensions
        if let croppedImage = cropImageToBusinessCardFrame(image) {
            // Apply image enhancement for business cards
            let enhancedImage = enhanceBusinessCardImage(croppedImage)
            delegate?.didCaptureImage(enhancedImage)
        } else {
            delegate?.didCaptureImage(image)
        }
    }
    
    private func cropImageToBusinessCardFrame(_ image: UIImage) -> UIImage? {
        guard let frameView = frameView else { return nil }
        
        // Get the orientation of the image
        let imageOrientation = image.imageOrientation
        let originalSize = image.size
        
        // Convert frame rect to image coordinates
        let viewSize = view.bounds.size
        
        // Calculate scaling factors based on orientation
        var scaleX: CGFloat
        var scaleY: CGFloat
        
        if imageOrientation.isPortrait {
            // In portrait orientation, width and height are swapped
            scaleX = originalSize.height / viewSize.width
            scaleY = originalSize.width / viewSize.height
        } else {
            scaleX = originalSize.width / viewSize.width
            scaleY = originalSize.height / viewSize.height
        }
        
        // Calculate frame in image coordinates
        let frameInView = frameView.frame
        var frameInImage = CGRect(
            x: frameInView.origin.x * scaleX,
            y: frameInView.origin.y * scaleY,
            width: frameInView.size.width * scaleX,
            height: frameInView.size.height * scaleY
        )
        
        // Adjust for image orientation if needed
        if imageOrientation.isPortrait {
            // Swap x and y coordinates for portrait orientation
            frameInImage = CGRect(
                x: frameInView.origin.y * scaleX,
                y: (viewSize.width - frameInView.origin.x - frameInView.size.width) * scaleY,
                width: frameInView.size.height * scaleX,
                height: frameInView.size.width * scaleY
            )
        }
        
        // Ensure the frame is within the image bounds
        let imageBounds = CGRect(origin: .zero, size: originalSize)
        frameInImage = frameInImage.intersection(imageBounds)
        
        // Crop the image
        if let cgImage = image.cgImage?.cropping(to: frameInImage) {
            // Create a new UIImage with the correct orientation
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return nil
    }
    
    private func enhanceBusinessCardImage(_ image: UIImage) -> UIImage {
        // Create a CIImage from the UIImage
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Create a context to perform the filters
        let context = CIContext(options: nil)
        
        // Apply filters to enhance the business card
        var filteredImage = ciImage
        
        // 1. Apply contrast and brightness adjustment
        if let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(filteredImage, forKey: kCIInputImageKey)
            filter.setValue(1.1, forKey: kCIInputContrastKey) // Slightly increase contrast
            filter.setValue(0.03, forKey: kCIInputBrightnessKey) // Slightly increase brightness
            
            if let outputImage = filter.outputImage {
                filteredImage = outputImage
            }
        }
        
        // 2. Apply unsharp mask to sharpen text
        if let filter = CIFilter(name: "CIUnsharpMask") {
            filter.setValue(filteredImage, forKey: kCIInputImageKey)
            filter.setValue(0.8, forKey: kCIInputRadiusKey) // Radius of the effect
            filter.setValue(0.6, forKey: kCIInputIntensityKey) // Intensity of the effect
            
            if let outputImage = filter.outputImage {
                filteredImage = outputImage
            }
        }
        
        // Convert back to UIImage
        if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.delegate?.didCancel()
        }))
        present(alert, animated: true)
    }
}

// Extension to check if orientation is portrait
extension UIImage.Orientation {
    var isPortrait: Bool {
        switch self {
        case .left, .leftMirrored, .right, .rightMirrored:
            return true
        default:
            return false
        }
    }
}

