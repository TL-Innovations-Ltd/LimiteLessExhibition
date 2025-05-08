//
//import UIKit
//import ARKit
//import SceneKit
//import RealityKit
//
//// Protocol for RoomScannerViewController
//protocol RoomScannerDelegate: AnyObject {
//    func roomScanningCompleted(corners: [SCNVector3], floorHeight: Float, ceilingHeight: Float)
//    func roomScanningCancelled()
//}
//
//class RoomScannerViewController: UIViewController, ARSCNViewDelegate {
//    weak var delegate: RoomScannerDelegate?
//
//    // MARK: - Properties
//    private var sceneView: ARSCNView!
//    private var roomCorners: [SCNVector3] = []
//    private var floorHeight: Float = 0
//    private var ceilingHeight: Float = 0
//    private var roomHeight: Float = 0
//    
//    // Corner markers and guides
//    private var cornerMarkers: [SCNNode] = []
//    private var lineNodes: [SCNNode] = []
//    private var targetNode: SCNNode?
//    private var floorPlaneNode: SCNNode?
//    private var heightMeasurementLine: SCNNode?
//    
//    // Define ScanningState enum inside the class
//    private enum ScanningState: Int {
//        case detectingFloor = 0
//        case floorCorner1 = 1
//        case floorCorner2 = 2
//        case floorCorner3 = 3
//        case floorCorner4 = 4
//        case measureHeight = 5
//        case complete = 6
//    }
//    
//    private var currentScanningState: ScanningState = .detectingFloor
//    private var isRoomVisible: Bool = false
//    
//    // UI Elements
//    private var instructionLabel: UILabel!
//    private var subInstructionLabel: UILabel!
//    private var scanButton: UIButton!
//    private var nextButton: UIButton!
//    private var resetButton: UIButton!
//    private var cancelButton: UIButton!
//    private var progressView: UIProgressView!
//    private var targetImageView: UIImageView!
//    
//    // For device-specific adjustments
//    private var isSmallDevice: Bool {
//        let screenHeight = UIScreen.main.bounds.height
//        return screenHeight <= 812 // iPhone 12 mini and smaller devices
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupARScene()
//        setupUI()
//        setupCancelButton()
//        setupProgressView()
//        setupTargetImageView()
//        optimizeForPerformance()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // Create AR configuration with improved tracking
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        
//        // Enable more advanced features if available
//        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
//            configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
//        }
//        
//        // Set environment texturing for better visual quality
//        if #available(iOS 13.0, *) {
//            configuration.environmentTexturing = .automatic
//        }
//        
//        // Run the view's session with improved tracking options
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        
//        // Start with floor detection
//        updateInstructionLabel()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Update UI element positions when view layout changes
//        updateUIForCurrentDevice()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupARScene() {
//        sceneView = ARSCNView(frame: view.bounds)
//        sceneView.delegate = self
//        sceneView.showsStatistics = false
//        sceneView.autoenablesDefaultLighting = true
//        sceneView.automaticallyUpdatesLighting = true
//        
//        // Enable debug options only in debug builds
//        #if DEBUG
//        sceneView.debugOptions = [.showFeaturePoints]
//        sceneView.showsStatistics = true
//        #endif
//        
//        view.addSubview(sceneView)
//        
//        // Add tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        sceneView.addGestureRecognizer(tapGesture)
//    }
//    
//    private func setupUI() {
//        // Main instruction label
//        instructionLabel = UILabel()
//        instructionLabel.textAlignment = .center
//        instructionLabel.numberOfLines = 0
//        instructionLabel.textColor = .white
//        instructionLabel.font = UIFont.systemFont(ofSize: isSmallDevice ? 18 : 20, weight: .bold)
//        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        instructionLabel.layer.cornerRadius = 10
//        instructionLabel.layer.masksToBounds = true
//        view.addSubview(instructionLabel)
//        
//        // Sub-instruction label for additional guidance
//        subInstructionLabel = UILabel()
//        subInstructionLabel.textAlignment = .center
//        subInstructionLabel.numberOfLines = 0
//        subInstructionLabel.textColor = .white
//        subInstructionLabel.font = UIFont.systemFont(ofSize: isSmallDevice ? 14 : 16, weight: .regular)
//        subInstructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        subInstructionLabel.layer.cornerRadius = 10
//        subInstructionLabel.layer.masksToBounds = true
//        view.addSubview(subInstructionLabel)
//        
//        // Scan button
//        scanButton = UIButton(type: .system)
//        scanButton.setTitle("Capture", for: .normal)
//        scanButton.backgroundColor = .systemBlue
//        scanButton.setTitleColor(.white, for: .normal)
//        scanButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 18, weight: .semibold)
//        scanButton.layer.cornerRadius = 10
//        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
//        view.addSubview(scanButton)
//        
//        // Next button (initially hidden)
//        nextButton = UIButton(type: .system)
//        nextButton.setTitle("Next Step", for: .normal)
//        nextButton.backgroundColor = .systemGreen
//        nextButton.setTitleColor(.white, for: .normal)
//        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 18, weight: .semibold)
//        nextButton.layer.cornerRadius = 10
//        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
//        nextButton.isHidden = true
//        view.addSubview(nextButton)
//        
//        // Reset button
//        resetButton = UIButton(type: .system)
//        resetButton.setTitle("Reset", for: .normal)
//        resetButton.backgroundColor = .systemRed
//        resetButton.setTitleColor(.white, for: .normal)
//        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 18, weight: .semibold)
//        resetButton.layer.cornerRadius = 10
//        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
//        view.addSubview(resetButton)
//        
//        // Position UI elements based on device size
//        updateUIForCurrentDevice()
//    }
//    
//    private func setupCancelButton() {
//        cancelButton = UIButton(type: .system)
//        cancelButton.setTitle("Cancel", for: .normal)
//        cancelButton.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
//        cancelButton.setTitleColor(.white, for: .normal)
//        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 14 : 16, weight: .medium)
//        cancelButton.layer.cornerRadius = 10
//        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
//        view.addSubview(cancelButton)
//        
//        // Position the cancel button
//        let topPadding: CGFloat = isSmallDevice ? 30 : 40
//        let buttonWidth: CGFloat = isSmallDevice ? 70 : 80
//        let buttonHeight: CGFloat = isSmallDevice ? 30 : 40
//        cancelButton.frame = CGRect(x: 20, y: topPadding, width: buttonWidth, height: buttonHeight)
//    }
//    
//
//    private func setupProgressView() {
//        progressView = UIProgressView(progressViewStyle: .bar)
//        progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.5)
//        progressView.progressTintColor = .systemBlue
//        progressView.layer.cornerRadius = 4
//        progressView.clipsToBounds = true
//        progressView.progress = 0.0
//        view.addSubview(progressView)
//        
//        // Position the progress view
//        let progressWidth: CGFloat = view.bounds.width - 40
//        let progressHeight: CGFloat = 8
//        let topPadding: CGFloat = isSmallDevice ? 80 : 100
//        progressView.frame = CGRect(x: 20, y: topPadding, width: progressWidth, height: progressHeight)
//    }
//    
//    private func setupTargetImageView() {
//        // Create a target/crosshair image view for better aiming
//        targetImageView = UIImageView()
//        targetImageView.contentMode = .scaleAspectFit
//        targetImageView.tintColor = .white
//        
//        // Create a crosshair image
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
//        let crosshairImage = renderer.image { ctx in
//            let rect = CGRect(x: 0, y: 0, width: 60, height: 60)
//            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
//            ctx.cgContext.setLineWidth(2)
//            
//            // Draw circle
//            ctx.cgContext.addEllipse(in: CGRect(x: 5, y: 5, width: 50, height: 50))
//            ctx.cgContext.strokePath()
//            
//            // Draw crosshair
//            ctx.cgContext.move(to: CGPoint(x: 30, y: 15))
//            ctx.cgContext.addLine(to: CGPoint(x: 30, y: 45))
//            ctx.cgContext.move(to: CGPoint(x: 15, y: 30))
//            ctx.cgContext.addLine(to: CGPoint(x: 45, y: 30))
//            ctx.cgContext.strokePath()
//        }
//        
//        targetImageView.image = crosshairImage.withRenderingMode(.alwaysTemplate)
//        targetImageView.alpha = 0.8
//        view.addSubview(targetImageView)
//        
//        // Center the target in the view
//        let targetSize: CGFloat = 60
//        targetImageView.frame = CGRect(
//            x: (view.bounds.width - targetSize) / 2,
//            y: (view.bounds.height - targetSize) / 2,
//            width: targetSize,
//            height: targetSize
//        )
//    }
//    
//    private func updateUIForCurrentDevice() {
//        // Adjust UI element positions and sizes based on device screen size
//        let safeAreaInsets = view.safeAreaInsets
//        let topPadding = safeAreaInsets.top + (isSmallDevice ? 10 : 20)
//        let bottomPadding = safeAreaInsets.bottom + (isSmallDevice ? 10 : 20)
//        let buttonHeight: CGFloat = isSmallDevice ? 40 : 50
//        let buttonWidth: CGFloat = isSmallDevice ? 130 : 150
//        let horizontalPadding: CGFloat = isSmallDevice ? 15 : 20
//        
//        // Main instruction label
//        let labelHeight: CGFloat = isSmallDevice ? 60 : 70
//        instructionLabel.frame = CGRect(
//            x: horizontalPadding,
//            y: topPadding + (isSmallDevice ? 30 : 40),
//            width: view.bounds.width - (horizontalPadding * 2),
//            height: labelHeight
//        )
//        
//        // Sub-instruction label
//        let subLabelHeight: CGFloat = isSmallDevice ? 50 : 60
//        subInstructionLabel.frame = CGRect(
//            x: horizontalPadding,
//            y: instructionLabel.frame.maxY + 10,
//            width: view.bounds.width - (horizontalPadding * 2),
//            height: subLabelHeight
//        )
//        
//        // Update progress view if it exists
//        if let progressView = self.progressView {
//            let progressWidth: CGFloat = view.bounds.width - 40
//            progressView.frame = CGRect(
//                x: 20,
//                y: subInstructionLabel.frame.maxY + 10,
//                width: progressWidth,
//                height: progressView.frame.height
//            )
//        }
//        
//        // Scan button
//        scanButton.frame = CGRect(
//            x: view.bounds.width/2 - buttonWidth/2,
//            y: view.bounds.height - bottomPadding - buttonHeight,
//            width: buttonWidth,
//            height: buttonHeight
//        )
//        
//        // Next button
//        nextButton.frame = CGRect(
//            x: view.bounds.width - buttonWidth - horizontalPadding,
//            y: view.bounds.height - bottomPadding - buttonHeight,
//            width: buttonWidth,
//            height: buttonHeight
//        )
//        
//        // Reset button
//        resetButton.frame = CGRect(
//            x: horizontalPadding,
//            y: view.bounds.height - bottomPadding - buttonHeight,
//            width: buttonWidth,
//            height: buttonHeight
//        )
//        
//        // Update target image view position if it exists
//        if let targetImageView = self.targetImageView {
//            let targetSize: CGFloat = 60
//            targetImageView.frame = CGRect(
//                x: (view.bounds.width - targetSize) / 2,
//                y: (view.bounds.height - targetSize) / 2,
//                width: targetSize,
//                height: targetSize
//            )
//        }
//    }
//    
//    // MARK: - Floor Detection
//    private func detectFloor() {
//        // Check if we have detected horizontal planes
//        let horizontalPlanes = sceneView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor }.filter { $0.alignment == .horizontal }
//        
//        if let planes = horizontalPlanes, !planes.isEmpty {
//            // Find the lowest plane (most likely to be the floor)
//            if let floorPlane = planes.min(by: { $0.transform.columns.3.y < $1.transform.columns.3.y }) {
//                // Create or update floor visualization
//                createOrUpdateFloorVisualization(for: floorPlane)
//                
//                // Enable the scan button once we have a floor
//                scanButton.isEnabled = true
//                scanButton.alpha = 1.0
//                
//                // Update instruction
//                subInstructionLabel.text = "Floor detected! Tap 'Capture' to confirm and start corner selection."
//            }
//        } else {
//            // No floor detected yet
//            scanButton.isEnabled = false
//            scanButton.alpha = 0.5
//            subInstructionLabel.text = "Move your device around to detect the floor."
//        }
//    }
//    
//    private func createOrUpdateFloorVisualization(for planeAnchor: ARPlaneAnchor) {
//        // Remove existing floor visualization
//        floorPlaneNode?.removeFromParentNode()
//        
//        // Create a new visualization
//        let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.green.withAlphaComponent(0.3)
//        planeGeometry.materials = [material]
//        
//        floorPlaneNode = SCNNode(geometry: planeGeometry)
//        floorPlaneNode?.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//        floorPlaneNode?.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
//        
//        // Add to scene
//        let anchorNode = sceneView.node(for: planeAnchor) ?? SCNNode()
//        anchorNode.addChildNode(floorPlaneNode!)
//    }
//    
//    // MARK: - Action Methods
//    @objc private func scanButtonTapped() {
//        switch currentScanningState {
//        case .detectingFloor:
//            // Confirm floor detection and move to corner selection
//            if let floorAnchor = sceneView.session.currentFrame?.anchors.compactMap({ $0 as? ARPlaneAnchor }).filter({ $0.alignment == .horizontal }).min(by: { $0.transform.columns.3.y < $1.transform.columns.3.y }) {
//                // Set floor height
//                floorHeight = Float(floorAnchor.transform.columns.3.y)
//                
//                // Move to first corner selection
//                currentScanningState = .floorCorner1
//                updateInstructionLabel()
//                updateProgressView()
//                
//                // Provide haptic feedback
//                let feedbackGenerator = UINotificationFeedbackGenerator()
//                feedbackGenerator.notificationOccurred(.success)
//            } else {
//                showAlert(title: "Floor Not Detected", message: "Please make sure you're pointing at a flat horizontal surface.")
//            }
//            
//        case .floorCorner1, .floorCorner2, .floorCorner3, .floorCorner4:
//            // Capture corner position
//            captureCorner()
//            
//        case .measureHeight:
//            // Capture ceiling height
//            captureCeilingHeight()
//            
//        case .complete:
//            break
//        }
//    }
//    
//    private func captureCorner() {
//        // Get the center of the screen
//        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
//        
//        // Perform hit test to find real-world position
//        let hitTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
//        
//        if let bestResult = hitTestResults.first {
//            let position = SCNVector3(
//                bestResult.worldTransform.columns.3.x,
//                floorHeight, // Use the established floor height
//                bestResult.worldTransform.columns.3.z
//            )
//            
//            // Add corner to our list
//            roomCorners.append(position)
//            
//            // Add visual marker
//            addCornerMarker(at: position)
//            
//            // If we have more than one corner, draw a line between them
//            if roomCorners.count > 1 {
//                addLineBetween(
//                    start: roomCorners[roomCorners.count - 2],
//                    end: roomCorners[roomCorners.count - 1]
//                )
//            }
//            
//            // If we've captured all 4 corners, connect the last corner to the first
//            if roomCorners.count == 4 {
//                addLineBetween(
//                    start: roomCorners[3],
//                    end: roomCorners[0]
//                )
//            }
//            
//            // Move to next state
//            if let nextState = ScanningState(rawValue: currentScanningState.rawValue + 1) {
//                currentScanningState = nextState
//                updateInstructionLabel()
//                updateProgressView()
//                
//                // Provide haptic feedback
//                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
//                feedbackGenerator.impactOccurred()
//            }
//        } else {
//            showAlert(title: "Cannot Detect Surface", message: "Please aim at the floor near the corner you want to capture.")
//        }
//    }
//    
//    private func captureCeilingHeight() {
//        // Get the center of the screen
//        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
//        
//        // Perform hit test to find ceiling
//        let hitTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent, .estimatedVerticalPlane])
//        
//        if let bestResult = hitTestResults.first {
//            let position = SCNVector3(
//                bestResult.worldTransform.columns.3.x,
//                bestResult.worldTransform.columns.3.y,
//                bestResult.worldTransform.columns.3.z
//            )
//            
//            // Set ceiling height
//            ceilingHeight = position.y
//            
//            // Ensure ceiling is higher than floor
//            if ceilingHeight <= floorHeight + 0.5 { // At least 0.5m higher than floor
//                ceilingHeight = floorHeight + 2.4 // Default to 2.4m (8ft) if detection fails
//                showAlert(title: "Height Detection Issue", message: "Using standard room height of 2.4m. You can adjust this later.")
//            }
//            
//            roomHeight = ceilingHeight - floorHeight
//            
//            // Add visual marker for ceiling point
//            addCeilingMarker(at: position)
//            
//            // Add vertical line to visualize height
//            if let firstCorner = roomCorners.first {
//                let floorPoint = SCNVector3(firstCorner.x, floorHeight, firstCorner.z)
//                let ceilingPoint = SCNVector3(firstCorner.x, ceilingHeight, firstCorner.z)
//                addHeightLine(from: floorPoint, to: ceilingPoint)
//            }
//            
//            // Move to complete state
//            currentScanningState = .complete
//            updateInstructionLabel()
//            updateProgressView()
//            
//            // Create the room model
//            createRoomModel()
//            
//            // Provide haptic feedback
//            let feedbackGenerator = UINotificationFeedbackGenerator()
//            feedbackGenerator.notificationOccurred(.success)
//        } else {
//            showAlert(title: "Cannot Detect Ceiling", message: "Please aim at the ceiling to measure room height.")
//        }
//    }
//    
//    @objc private func nextButtonTapped() {
//        // Navigate to model placement
//        navigateToModelPlacementVC()
//    }
//    
//    @objc private func resetButtonTapped() {
//        // Reset all scanning data
//        roomCorners.removeAll()
//        cornerMarkers.forEach { $0.removeFromParentNode() }
//        cornerMarkers.removeAll()
//        lineNodes.forEach { $0.removeFromParentNode() }
//        lineNodes.removeAll()
//        heightMeasurementLine?.removeFromParentNode()
//        heightMeasurementLine = nil
//        targetNode?.removeFromParentNode()
//        targetNode = nil
//        
//        floorHeight = 0
//        ceilingHeight = 0
//        roomHeight = 0
//        
//        // Reset scanning state
//        currentScanningState = .detectingFloor
//        isRoomVisible = false
//        
//        // Clear all room nodes
//        sceneView.scene.rootNode.childNodes.forEach { node in
//            if node != sceneView.pointOfView && (node.name?.contains("room") ?? false) {
//                node.removeFromParentNode()
//            }
//        }
//        
//        // Reset UI
//        updateInstructionLabel()
//        updateProgressView()
//        nextButton.isHidden = true
//        
//        // Provide haptic feedback
//        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
//        feedbackGenerator.impactOccurred()
//    }
//    
//    @objc private func cancelButtonTapped() {
//        // Notify delegate that scanning was cancelled
//        delegate?.roomScanningCancelled()
//        
//        // Provide haptic feedback
//        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
//        feedbackGenerator.impactOccurred()
//    }
//    
//    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//        // Get the location of the tap in the AR scene view
//        let location = gestureRecognizer.location(in: sceneView)
//        
//        switch currentScanningState {
//        case .floorCorner1, .floorCorner2, .floorCorner3, .floorCorner4:
//            // Perform hit test to find floor position
//            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
//            
//            if let bestResult = hitTestResults.first {
//                let position = SCNVector3(
//                    bestResult.worldTransform.columns.3.x,
//                    floorHeight, // Use the established floor height
//                    bestResult.worldTransform.columns.3.z
//                )
//                
//                // Add corner to our list
//                roomCorners.append(position)
//                
//                // Add visual marker
//                addCornerMarker(at: position)
//                
//                // If we have more than one corner, draw a line between them
//                if roomCorners.count > 1 {
//                    addLineBetween(
//                        start: roomCorners[roomCorners.count - 2],
//                        end: roomCorners[roomCorners.count - 1]
//                    )
//                }
//                
//                // If we've captured all 4 corners, connect the last corner to the first
//                if roomCorners.count == 4 {
//                    addLineBetween(
//                        start: roomCorners[3],
//                        end: roomCorners[0]
//                    )
//                }
//                
//                // Move to next state
//                if let nextState = ScanningState(rawValue: currentScanningState.rawValue + 1) {
//                    currentScanningState = nextState
//                    updateInstructionLabel()
//                    updateProgressView()
//                    
//                    // Provide haptic feedback
//                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
//                    feedbackGenerator.impactOccurred()
//                }
//            }
//            
//        case .measureHeight:
//            // Perform hit test to find ceiling
//            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedVerticalPlane])
//            
//            if let bestResult = hitTestResults.first {
//                let position = SCNVector3(
//                    bestResult.worldTransform.columns.3.x,
//                    bestResult.worldTransform.columns.3.y,
//                    bestResult.worldTransform.columns.3.z
//                )
//                
//                // Only accept points that are higher than the floor
//                if position.y > floorHeight + 0.5 {
//                    // Set ceiling height
//                    ceilingHeight = position.y
//                    roomHeight = ceilingHeight - floorHeight
//                    
//                    // Add visual marker for ceiling point
//                    addCeilingMarker(at: position)
//                    
//                    // Add vertical line to visualize height
//                    if let firstCorner = roomCorners.first {
//                        let floorPoint = SCNVector3(firstCorner.x, floorHeight, firstCorner.z)
//                        let ceilingPoint = SCNVector3(firstCorner.x, ceilingHeight, firstCorner.z)
//                        addHeightLine(from: floorPoint, to: ceilingPoint)
//                    }
//                    
//                    // Move to complete state
//                    currentScanningState = .complete
//                    updateInstructionLabel()
//                    updateProgressView()
//                    
//                    // Create the room model
//                    createRoomModel()
//                    
//                    // Provide haptic feedback
//                    let feedbackGenerator = UINotificationFeedbackGenerator()
//                    feedbackGenerator.notificationOccurred(.success)
//                }
//            }
//            
//        default:
//            break
//        }
//    }
//    
//    // MARK: - UI Update Methods
//    private func updateInstructionLabel() {
//        switch currentScanningState {
//        case .detectingFloor:
//            instructionLabel.text = "Step 1: Detect Floor"
//            subInstructionLabel.text = "Move your device around to detect the floor."
//            scanButton.setTitle("Confirm Floor", for: .normal)
//            nextButton.isHidden = true
//            
//            // Start floor detection
//            detectFloor()
//            
//        case .floorCorner1:
//            instructionLabel.text = "Step 2: Select First Corner"
//            subInstructionLabel.text = "Point at the first corner of the room and tap 'Capture'."
//            scanButton.setTitle("Capture Corner", for: .normal)
//            nextButton.isHidden = true
//            
//            // Show target for better aiming
//            targetImageView.tintColor = .green
//            
//        case .floorCorner2:
//            instructionLabel.text = "Step 3: Select Second Corner"
//            subInstructionLabel.text = "Point at the second corner of the room and tap 'Capture'."
//            scanButton.setTitle("Capture Corner", for: .normal)
//            nextButton.isHidden = true
//            
//        case .floorCorner3:
//            instructionLabel.text = "Step 4: Select Third Corner"
//            subInstructionLabel.text = "Point at the third corner of the room and tap 'Capture'."
//            scanButton.setTitle("Capture Corner", for: .normal)
//            nextButton.isHidden = true
//            
//        case .floorCorner4:
//            instructionLabel.text = "Step 5: Select Fourth Corner"
//            subInstructionLabel.text = "Point at the fourth corner of the room and tap 'Capture'."
//            scanButton.setTitle("Capture Corner", for: .normal)
//            nextButton.isHidden = true
//            
//        case .measureHeight:
//            instructionLabel.text = "Step 6: Measure Room Height"
//            subInstructionLabel.text = "Point at the ceiling and tap 'Capture Height'."
//            scanButton.setTitle("Capture Height", for: .normal)
//            nextButton.isHidden = true
//            
//            // Change target color for ceiling detection
//            targetImageView.tintColor = .blue
//            
//        case .complete:
//            instructionLabel.text = "Room Scanning Complete!"
//            subInstructionLabel.text = "Room model created successfully. Height: \(String(format: "%.2f", roomHeight)) meters"
//            scanButton.isHidden = true
//            nextButton.isHidden = false
//            nextButton.setTitle("Place 3D Models", for: .normal)
//            
//            // Hide target
//            targetImageView.isHidden = true
//        }
//    }
//    
//    private func updateProgressView() {
//        // Calculate progress based on current state
//        let totalSteps = 6.0 // Total number of steps in the process
//        let currentStep = Float(currentScanningState.rawValue) / Float(totalSteps)
//        
//        // Animate progress update
//        UIView.animate(withDuration: 0.3) {
//            self.progressView.setProgress(currentStep, animated: true)
//        }
//    }
//    
//    // MARK: - Visual Markers
//    private func addCornerMarker(at position: SCNVector3) {
//        let sphere = SCNSphere(radius: 0.03)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        material.emission.contents = UIColor.red.withAlphaComponent(0.5) // Add glow effect
//        sphere.materials = [material]
//        
//        let sphereNode = SCNNode(geometry: sphere)
//        sphereNode.position = position
//        sphereNode.name = "corner_marker_\(cornerMarkers.count)"
//        
//        // Add a pulsing animation to make it more visible
//        let pulseAction = SCNAction.sequence([
//            SCNAction.scale(to: 1.2, duration: 0.5),
//            SCNAction.scale(to: 1.0, duration: 0.5)
//        ])
//        sphereNode.runAction(SCNAction.repeatForever(pulseAction))
//        
//        // Add to scene and track
//        sceneView.scene.rootNode.addChildNode(sphereNode)
//        cornerMarkers.append(sphereNode)
//        
//        // Add corner number label
//        addCornerLabel(at: position, number: cornerMarkers.count)
//    }
//    
//    private func addCornerLabel(at position: SCNVector3, number: Int) {
//        // Create a text geometry for the corner number
//        let text = SCNText(string: "\(number)", extrusionDepth: 0.1)
//        text.font = UIFont.systemFont(ofSize: 0.5)
//        text.firstMaterial?.diffuse.contents = UIColor.white
//        
//        // Create a node for the text
//        let textNode = SCNNode(geometry: text)
//        textNode.scale = SCNVector3(0.05, 0.05, 0.05) // Scale down the text
//        
//        // Position the text above the corner marker
//        textNode.position = SCNVector3(position.x, position.y + 0.1, position.z)
//        
//        // Make the text always face the camera
//        let billboardConstraint = SCNBillboardConstraint()
//        textNode.constraints = [billboardConstraint]
//        
//        // Add to scene
//        sceneView.scene.rootNode.addChildNode(textNode)
//    }
//    
//    private func addCeilingMarker(at position: SCNVector3) {
//        let sphere = SCNSphere(radius: 0.03)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.blue
//        material.emission.contents = UIColor.blue.withAlphaComponent(0.5) // Add glow effect
//        sphere.materials = [material]
//        
//        let sphereNode = SCNNode(geometry: sphere)
//        sphereNode.position = position
//        sphereNode.name = "ceiling_marker"
//        
//        // Add a pulsing animation
//        let pulseAction = SCNAction.sequence([
//            SCNAction.scale(to: 1.2, duration: 0.5),
//            SCNAction.scale(to: 1.0, duration: 0.5)
//        ])
//        sphereNode.runAction(SCNAction.repeatForever(pulseAction))
//        
//        // Add to scene
//        sceneView.scene.rootNode.addChildNode(sphereNode)
//    }
//    
//    private func addLineBetween(start: SCNVector3, end: SCNVector3) {
//        let line = SCNGeometry.lineFrom(vector: start, toVector: end)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.yellow
//        material.emission.contents = UIColor.yellow.withAlphaComponent(0.5) // Add glow effect
//        line.materials = [material]
//        
//        let lineNode = SCNNode(geometry: line)
//        lineNode.name = "corner_line"
//        
//        // Add to scene and track
//        sceneView.scene.rootNode.addChildNode(lineNode)
//        lineNodes.append(lineNode)
//    }
//    
//    private func addHeightLine(from start: SCNVector3, to end: SCNVector3) {
//        let line = SCNGeometry.lineFrom(vector: start, toVector: end)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.green
//        material.emission.contents = UIColor.green.withAlphaComponent(0.5) // Add glow effect
//        line.materials = [material]
//        
//        heightMeasurementLine = SCNNode(geometry: line)
//        heightMeasurementLine?.name = "height_line"
//        
//        // Add to scene
//        sceneView.scene.rootNode.addChildNode(heightMeasurementLine!)
//        
//        // Add height label
//        let heightText = SCNText(string: String(format: "%.2f m", roomHeight), extrusionDepth: 0.1)
//        heightText.font = UIFont.systemFont(ofSize: 0.5)
//        heightText.firstMaterial?.diffuse.contents = UIColor.white
//        
//        let textNode = SCNNode(geometry: heightText)
//        textNode.scale = SCNVector3(0.05, 0.05, 0.05) // Scale down the text
//        
//        // Position the text in the middle of the height line
//        let midPoint = SCNVector3(
//            (start.x + end.x) / 2,
//            (start.y + end.y) / 2,
//            (start.z + end.z) / 2
//        )
//        textNode.position = midPoint
//        
//        // Make the text always face the camera
//        let billboardConstraint = SCNBillboardConstraint()
//        textNode.constraints = [billboardConstraint]
//        
//        // Add to scene
//        sceneView.scene.rootNode.addChildNode(textNode)
//    }
//    
//    // MARK: - Room Model Creation
//    private func createRoomModel() {
//        guard roomCorners.count == 4, roomHeight > 0 else {
//            showAlert(title: "Error", message: "Incomplete room data")
//            return
//        }
//        
//        // Hide markers and lines
//        cornerMarkers.forEach { $0.isHidden = true }
//        lineNodes.forEach { $0.isHidden = true }
//        heightMeasurementLine?.isHidden = true
//        
//        // Create floor
//        createFloor()
//        
//        // Create ceiling
//        createCeiling()
//        
//        // Create walls
//        createWalls()
//        
//        // Add ambient lighting
//        addAmbientLighting()
//        
//        // Mark room as visible
//        isRoomVisible = true
//        
//        // Show success message
//        showAlert(title: "Room Model Created", message: "Room dimensions captured successfully. Height: \(String(format: "%.2f", roomHeight)) meters")
//    }
//    
//    private func createFloor() {
//        // Create a custom shape for the floor based on the 4 corners
//        let floorNode = createPolygonNode(
//            points: roomCorners,
//            height: floorHeight,
//            color: UIColor.gray.withAlphaComponent(0.5),
//            isFloor: true
//        )
//        floorNode.name = "room_floor" // Add name for identification
//        
//        // Add physics body for collision detection
//        let shape = SCNPhysicsShape(node: floorNode, options: nil)
//        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
//        floorNode.physicsBody?.categoryBitMask = 1
//        
//        sceneView.scene.rootNode.addChildNode(floorNode)
//    }
//    
//    private func createCeiling() {
//        // Create ceiling corners by projecting floor corners upward
//        let ceilingCorners = roomCorners.map { SCNVector3($0.x, ceilingHeight, $0.z) }
//        
//        // Create a custom shape for the ceiling
//        let ceilingNode = createPolygonNode(
//            points: ceilingCorners,
//            height: ceilingHeight,
//            color: UIColor.white.withAlphaComponent(0.5),
//            isFloor: false
//        )
//        ceilingNode.name = "room_ceiling" // Add name for identification
//        
//        // Add physics body for collision detection
//        let shape = SCNPhysicsShape(node: ceilingNode, options: nil)
//        ceilingNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
//        ceilingNode.physicsBody?.categoryBitMask = 1
//        
//        sceneView.scene.rootNode.addChildNode(ceilingNode)
//    }
//    
//    private func createWalls() {
//        // Create walls by connecting floor and ceiling corners
//        for i in 0..<roomCorners.count {
//            let nextIndex = (i + 1) % roomCorners.count
//            
//            let floorPoint1 = roomCorners[i]
//            let floorPoint2 = roomCorners[nextIndex]
//            let ceilingPoint1 = SCNVector3(floorPoint1.x, ceilingHeight, floorPoint1.z)
//            let ceilingPoint2 = SCNVector3(floorPoint2.x, ceilingHeight, floorPoint2.z)
//            
//            // Create wall vertices
//            let vertices = [
//                floorPoint1,
//                floorPoint2,
//                ceilingPoint2,
//                ceilingPoint1
//            ]
//            
//            // Create wall node
//            let wallNode = createWallNode(vertices: vertices, color: UIColor.lightGray.withAlphaComponent(0.5))
//            wallNode.name = "room_wall_\(i)" // Add name for identification
//            
//            // Add physics body for collision detection
//            let shape = SCNPhysicsShape(node: wallNode, options: nil)
//            wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
//            wallNode.physicsBody?.categoryBitMask = 1
//            
//            sceneView.scene.rootNode.addChildNode(wallNode)
//        }
//    }
//    
//    private func addAmbientLighting() {
//        // Add ambient light to the scene
//        let ambientLight = SCNLight()
//        ambientLight.type = .ambient
//        ambientLight.intensity = 500
//        ambientLight.color = UIColor.white
//        
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = ambientLight
//        ambientLightNode.name = "ambient_light"
//        sceneView.scene.rootNode.addChildNode(ambientLightNode)
//        
//        // Add directional light to simulate sunlight
//        let directionalLight = SCNLight()
//        directionalLight.type = .directional
//        directionalLight.intensity = 1000
//        directionalLight.castsShadow = true
//        directionalLight.shadowMode = .deferred
//        directionalLight.shadowColor = UIColor.black.withAlphaComponent(0.5)
//        
//        let directionalLightNode = SCNNode()
//        directionalLightNode.light = directionalLight
//        directionalLightNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0)
//        directionalLightNode.name = "directional_light"
//        sceneView.scene.rootNode.addChildNode(directionalLightNode)
//    }
//    
//    private func createPolygonNode(points: [SCNVector3], height: Float, color: UIColor, isFloor: Bool) -> SCNNode {
//        // Create vertices for the polygon
//        let vertices = points.map { SCNVector3($0.x, height, $0.z) }
//        
//        // Create geometry source from vertices
//        let source = SCNGeometrySource(vertices: vertices)
//        
//        // Create indices for the polygon triangulation
//        // For simplicity, we'll assume a convex polygon and use a fan triangulation
//        var indices: [Int32] = []
//        for i in 1..<(vertices.count - 1) {
//            indices.append(0)
//            indices.append(Int32(i))
//            indices.append(Int32(i + 1))
//        }
//        
//        // Create geometry element
//        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
//        
//        // Create geometry and set material
//        let geometry = SCNGeometry(sources: [source], elements: [element])
//        let material = SCNMaterial()
//        material.diffuse.contents = color
//        material.specular.contents = UIColor.white
//        material.shininess = 50
//        material.isDoubleSided = true
//        geometry.materials = [material]
//        
//        // Create and return node
//        let node = SCNNode(geometry: geometry)
//        
//        // If it's a floor, we need to make sure the normal is pointing up
//        if isFloor {
//            node.eulerAngles = SCNVector3(Float.pi, 0, 0)
//        }
//        
//        return node
//    }
//    
//    private func createWallNode(vertices: [SCNVector3], color: UIColor) -> SCNNode {
//        // Create geometry source from vertices
//        let source = SCNGeometrySource(vertices: vertices)
//        
//        // Create indices for two triangles forming a quad
//        let indices: [Int32] = [0, 1, 2, 0, 2, 3]
//        
//        // Create geometry element
//        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
//        
//        // Create geometry and set material
//        let geometry = SCNGeometry(sources: [source], elements: [element])
//        let material = SCNMaterial()
//        material.diffuse.contents = color
//        material.specular.contents = UIColor.white
//        material.shininess = 50
//        material.isDoubleSided = true
//        geometry.materials = [material]
//        
//        // Create and return node
//        return SCNNode(geometry: geometry)
//    }
//    
//    private func navigateToModelPlacementVC() {
//        // If we're using UIKit navigation
//        if let navigationController = navigationController {
//            let modelPlacementVC = ModelPlacementViewController(
//                roomCorners: roomCorners,
//                floorHeight: floorHeight,
//                ceilingHeight: ceilingHeight
//            )
//            navigationController.pushViewController(modelPlacementVC, animated: true)
//        } else {
//            // If we're using SwiftUI integration, notify the delegate
//            delegate?.roomScanningCompleted(
//                corners: roomCorners,
//                floorHeight: floorHeight,
//                ceilingHeight: ceilingHeight
//            )
//        }
//    }
//    
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    // MARK: - Performance Optimization
//    func optimizeForPerformance() {
//        // Reduce rendering quality for better performance
//        sceneView.antialiasingMode = .none
//        
//        // Disable unnecessary features
//        sceneView.automaticallyUpdatesLighting = false
//        
//        // Reduce scene complexity
//        sceneView.isJitteringEnabled = false
//        
//        // Optimize physics simulation
//        sceneView.scene.physicsWorld.speed = 0.5
//        
//        // Set reasonable debug options
//        #if DEBUG
//        sceneView.debugOptions = [.showFeaturePoints]
//        #else
//        sceneView.debugOptions = []
//        #endif
//        
//        // Optimize for iPhone 12 mini and other smaller devices
//        if isSmallDevice {
//            sceneView.preferredFramesPerSecond = 30 // Lower frame rate for better performance
//        }
//    }
//    
//    // MARK: - ARSCNViewDelegate
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        DispatchQueue.main.async {
//            // Update floor detection in detecting floor state
//            if self.currentScanningState == .detectingFloor {
//                self.detectFloor()
//            }
//        }
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // Handle newly added anchors
//        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
//            // If we're in floor detection mode, update the floor visualization
//            if currentScanningState == .detectingFloor {
//                DispatchQueue.main.async {
//                    self.createOrUpdateFloorVisualization(for: planeAnchor)
//                }
//            }
//        }
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        // Update existing anchors
//        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
//            // If we're in floor detection mode, update the floor visualization
//            if currentScanningState == .detectingFloor {
//                DispatchQueue.main.async {
//                    self.createOrUpdateFloorVisualization(for: planeAnchor)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Extensions
//extension SCNGeometry {
//    static func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
//        let indices: [Int32] = [0, 1]
//        
//        let source = SCNGeometrySource(vertices: [vector1, vector2])
//        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
//        
//        return SCNGeometry(sources: [source], elements: [element])
//    }
//}
