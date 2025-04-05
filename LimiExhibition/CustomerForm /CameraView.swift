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
        captureSession?.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            showAlert(message: "Unable to access camera")
            return
        }
        
        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if captureSession?.canAddOutput(photoOutput!) == true {
            captureSession?.addOutput(photoOutput!)
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
        
        // Add business card frame overlay
        let frameSize = CGSize(width: view.bounds.width * 0.8, height: view.bounds.width * 0.5) // Business card aspect ratio ~1.6:1
        let frameX = (view.bounds.width - frameSize.width) / 2
        let frameY = (view.bounds.height - frameSize.height) / 2
        
        frameView = UIView(frame: CGRect(x: frameX, y: frameY, width: frameSize.width, height: frameSize.height))
        frameView?.layer.borderColor = UIColor.white.cgColor
        frameView?.layer.borderWidth = 2.0
        frameView?.backgroundColor = UIColor.clear
        
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
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func cancelCapture() {
        delegate?.didCancel()
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
        
        // Crop image to frame
        if let croppedImage = cropImageToFrame(image) {
            delegate?.didCaptureImage(croppedImage)
        } else {
            delegate?.didCaptureImage(image)
        }
    }
    
    private func cropImageToFrame(_ image: UIImage) -> UIImage? {
        guard let frameView = frameView else { return nil }
        
        // Convert frame rect to image coordinates
        let imageSize = image.size
        let viewSize = view.bounds.size
        
        // Calculate scaling factors
        let scaleX = imageSize.width / viewSize.width
        let scaleY = imageSize.height / viewSize.height
        
        // Calculate frame in image coordinates
        let frameInView = frameView.frame
        let frameInImage = CGRect(
            x: frameInView.origin.x * scaleX,
            y: frameInView.origin.y * scaleY,
            width: frameInView.size.width * scaleX,
            height: frameInView.size.height * scaleY
        )
        
        // Crop the image
        if let cgImage = image.cgImage?.cropping(to: frameInImage) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return nil
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.delegate?.didCancel()
        }))
        present(alert, animated: true)
    }
}