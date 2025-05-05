import UIKit
import ARKit
import SceneKit
import RealityKit

// Protocol for RoomScannerViewController
protocol RoomScannerDelegate: AnyObject {
    func roomScanningCompleted(corners: [SCNVector3], floorHeight: Float, ceilingHeight: Float)
    func roomScanningCancelled()
}



class RoomScannerViewController: UIViewController, ARSCNViewDelegate {
    weak var delegate: RoomScannerDelegate?

    // MARK: - Properties
    private var sceneView: ARSCNView!
    private var roomCorners: [SCNVector3] = []
    private var floorHeight: Float = 0
    private var ceilingHeight: Float = 0
    private var roomHeight: Float = 0
    
    // Define ScanningState enum inside the class
    private enum ScanningState: Int {
        case floorCorner1 = 0
        case floorCorner2 = 1
        case floorCorner3 = 2
        case floorCorner4 = 3
        case measureHeight = 4
        case complete = 5
    }
    
    private var currentScanningState: ScanningState = .floorCorner1
    
    // UI Elements
    private var instructionLabel: UILabel!
    private var scanButton: UIButton!
    private var nextButton: UIButton!
    private var resetButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARScene()
        setupUI()
        optimizeForPerformance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create AR configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Setup Methods
    private func setupARScene() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        view.addSubview(sceneView)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        // Instruction label
        instructionLabel = UILabel()
        instructionLabel.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 80)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .white
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 10
        instructionLabel.layer.masksToBounds = true
        instructionLabel.text = "Scan the first corner of the room's floor"
        view.addSubview(instructionLabel)
        
        // Scan button
        scanButton = UIButton(type: .system)
        scanButton.frame = CGRect(x: view.bounds.width/2 - 75, y: view.bounds.height - 120, width: 150, height: 50)
        scanButton.setTitle("Capture Point", for: .normal)
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.layer.cornerRadius = 10
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        view.addSubview(scanButton)
        
        // Next button (initially hidden)
        nextButton = UIButton(type: .system)
        nextButton.frame = CGRect(x: view.bounds.width - 170, y: view.bounds.height - 120, width: 150, height: 50)
        nextButton.setTitle("Next Step", for: .normal)
        nextButton.backgroundColor = .systemGreen
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.isHidden = true
        view.addSubview(nextButton)
        
        // Reset button
        resetButton = UIButton(type: .system)
        resetButton.frame = CGRect(x: 20, y: view.bounds.height - 120, width: 150, height: 50)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.backgroundColor = .systemRed
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 10
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        view.addSubview(resetButton)
    }
    
    // MARK: - Action Methods
    @objc private func scanButtonTapped() {
        // Get the center of the screen
        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        
        // Perform hit test to find real-world position
        if let hitTestResult = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane]).first {
            let position = SCNVector3(
                hitTestResult.worldTransform.columns.3.x,
                hitTestResult.worldTransform.columns.3.y,
                hitTestResult.worldTransform.columns.3.z
            )
            
            // Process the captured point based on current state
            processScannedPoint(position)
        } else {
            // Show error if no plane detected
            showAlert(title: "Cannot detect surface", message: "Make sure you're pointing at a flat surface")
        }
    }
    
    @objc private func nextButtonTapped() {
        switch currentScanningState {
        case .floorCorner1, .floorCorner2, .floorCorner3:
            // Move to next corner - use the rawValue directly
            if let nextState = ScanningState(rawValue: currentScanningState.rawValue + 1) {
                currentScanningState = nextState
                updateInstructionLabel()
                nextButton.isHidden = true
            }
            
        case .floorCorner4:
            // Move to height measurement
            currentScanningState = .measureHeight
            updateInstructionLabel()
            nextButton.isHidden = true
            
        case .measureHeight:
            // Complete the scanning process
            currentScanningState = .complete
            createRoomModel()
            navigateToModelPlacementVC()
            
        case .complete:
            break
        }
    }
    
    @objc private func resetButtonTapped() {
        // Reset all scanning data
        roomCorners.removeAll()
        floorHeight = 0
        ceilingHeight = 0
        roomHeight = 0
        currentScanningState = .floorCorner1
        
        // Clear all nodes except the root node
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        updateInstructionLabel()
        nextButton.isHidden = true
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Get the location of the tap in the AR scene view
        let location = gestureRecognizer.location(in: sceneView)
        
        // Perform hit test to find real-world position
        if let hitTestResult = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane]).first {
            let position = SCNVector3(
                hitTestResult.worldTransform.columns.3.x,
                hitTestResult.worldTransform.columns.3.y,
                hitTestResult.worldTransform.columns.3.z
            )
            
            // Process the captured point based on current state
            processScannedPoint(position)
        }
    }
    
    // MARK: - Helper Methods
    private func processScannedPoint(_ position: SCNVector3) {
        switch currentScanningState {
        case .floorCorner1, .floorCorner2, .floorCorner3, .floorCorner4:
            // Add corner point
            roomCorners.append(position)
            
            // If this is the first point, set floor height
            if currentScanningState == .floorCorner1 {
                floorHeight = position.y
            }
            
            // Add visual marker at the scanned point
            addSphereMarker(at: position, color: .red)
            
            // If we have more than one corner, draw a line between them
            if roomCorners.count > 1 {
                addLineBetween(
                    start: roomCorners[roomCorners.count - 2],
                    end: roomCorners[roomCorners.count - 1],
                    color: .yellow
                )
            }
            
            // If we've scanned all 4 corners, connect the last corner to the first
            if roomCorners.count == 4 {
                addLineBetween(
                    start: roomCorners[3],
                    end: roomCorners[0],
                    color: .yellow
                )
            }
            
            // Update UI
            nextButton.isHidden = false
            
            // Move to next state if not manually controlled
            if currentScanningState != .floorCorner4 {
                if let nextState = ScanningState(rawValue: currentScanningState.rawValue + 1) {
                    currentScanningState = nextState
                    updateInstructionLabel()
                }
            }
            
        case .measureHeight:
            // Capture ceiling height
            ceilingHeight = position.y
            roomHeight = ceilingHeight - floorHeight
            
            // Add visual marker
            addSphereMarker(at: position, color: .blue)
            
            // Add vertical line to visualize height
            if let firstCorner = roomCorners.first {
                let floorPoint = SCNVector3(firstCorner.x, floorHeight, firstCorner.z)
                let ceilingPoint = SCNVector3(firstCorner.x, ceilingHeight, firstCorner.z)
                addLineBetween(start: floorPoint, end: ceilingPoint, color: .green)
            }
            
            // Update UI
            nextButton.isHidden = false
            nextButton.setTitle("Create Room", for: .normal)
            
        case .complete:
            break
        }
    }
    
    private func updateInstructionLabel() {
        switch currentScanningState {
        case .floorCorner1:
            instructionLabel.text = "Scan the first corner of the room's floor"
        case .floorCorner2:
            instructionLabel.text = "Scan the second corner of the room's floor"
        case .floorCorner3:
            instructionLabel.text = "Scan the third corner of the room's floor"
        case .floorCorner4:
            instructionLabel.text = "Scan the fourth corner of the room's floor"
        case .measureHeight:
            instructionLabel.text = "Point at the ceiling to measure room height"
        case .complete:
            instructionLabel.text = "Room scanning complete!"
        }
    }
    
    private func addSphereMarker(at position: SCNVector3, color: UIColor) {
        let sphere = SCNSphere(radius: 0.03)
        sphere.firstMaterial?.diffuse.contents = color
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    private func addLineBetween(start: SCNVector3, end: SCNVector3, color: UIColor) {
        let line = SCNGeometry.lineFrom(vector: start, toVector: end)
        line.firstMaterial?.diffuse.contents = color
        
        let lineNode = SCNNode(geometry: line)
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    // MARK: - Room Model Creation
    // Fix: Combine the two createRoomModel implementations
    private func createRoomModel() {
        guard roomCorners.count == 4, roomHeight > 0 else {
            showAlert(title: "Error", message: "Incomplete room data")
            return
        }
        
        // Create floor
        createFloor()
        
        // Create ceiling
        createCeiling()
        
        // Create walls
        createWalls()
        
        // Update UI
        instructionLabel.text = "Room model created successfully!"
        scanButton.isHidden = true
        nextButton.isHidden = false
        nextButton.setTitle("Place 3D Models", for: .normal)
        
        // Show success message
        showAlert(title: "Room Model Created", message: "Room dimensions captured successfully. Height: \(roomHeight) meters")
    }
    
    private func createFloor() {
        // Create a custom shape for the floor based on the 4 corners
        let floorNode = createPolygonNode(
            points: roomCorners,
            height: floorHeight,
            color: UIColor.gray.withAlphaComponent(0.5),
            isFloor: true
        )
        floorNode.name = "room_floor" // Add name for identification
        sceneView.scene.rootNode.addChildNode(floorNode)
    }
    
    private func createCeiling() {
        // Create ceiling corners by projecting floor corners upward
        let ceilingCorners = roomCorners.map { SCNVector3($0.x, ceilingHeight, $0.z) }
        
        // Create a custom shape for the ceiling
        let ceilingNode = createPolygonNode(
            points: ceilingCorners,
            height: ceilingHeight,
            color: UIColor.white.withAlphaComponent(0.5),
            isFloor: false
        )
        ceilingNode.name = "room_ceiling" // Add name for identification
        sceneView.scene.rootNode.addChildNode(ceilingNode)
    }
    
    private func createWalls() {
        // Create walls by connecting floor and ceiling corners
        for i in 0..<roomCorners.count {
            let nextIndex = (i + 1) % roomCorners.count
            
            let floorPoint1 = roomCorners[i]
            let floorPoint2 = roomCorners[nextIndex]
            let ceilingPoint1 = SCNVector3(floorPoint1.x, ceilingHeight, floorPoint1.z)
            let ceilingPoint2 = SCNVector3(floorPoint2.x, ceilingHeight, floorPoint2.z)
            
            // Create wall vertices
            let vertices = [
                floorPoint1,
                floorPoint2,
                ceilingPoint2,
                ceilingPoint1
            ]
            
            // Create wall node
            let wallNode = createWallNode(vertices: vertices, color: UIColor.lightGray.withAlphaComponent(0.5))
            wallNode.name = "room_wall" // Add name for identification
            sceneView.scene.rootNode.addChildNode(wallNode)
        }
    }
    
    private func createPolygonNode(points: [SCNVector3], height: Float, color: UIColor, isFloor: Bool) -> SCNNode {
        // Create vertices for the polygon
        let vertices = points.map { SCNVector3($0.x, height, $0.z) }
        
        // Create geometry source from vertices
        let source = SCNGeometrySource(vertices: vertices)
        
        // Create indices for the polygon triangulation
        // For simplicity, we'll assume a convex polygon and use a fan triangulation
        var indices: [Int32] = []
        for i in 1..<(vertices.count - 1) {
            indices.append(0)
            indices.append(Int32(i))
            indices.append(Int32(i + 1))
        }
        
        // Create geometry element
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        // Create geometry and set material
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.isDoubleSided = true
        geometry.materials = [material]
        
        // Create and return node
        let node = SCNNode(geometry: geometry)
        
        // If it's a floor, we need to make sure the normal is pointing up
        if isFloor {
            node.eulerAngles = SCNVector3(Float.pi, 0, 0)
        }
        
        return node
    }
    
    private func createWallNode(vertices: [SCNVector3], color: UIColor) -> SCNNode {
        // Create geometry source from vertices
        let source = SCNGeometrySource(vertices: vertices)
        
        // Create indices for two triangles forming a quad
        let indices: [Int32] = [0, 1, 2, 0, 2, 3]
        
        // Create geometry element
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        // Create geometry and set material
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.isDoubleSided = true
        geometry.materials = [material]
        
        // Create and return node
        return SCNNode(geometry: geometry)
    }
    
    private func navigateToModelPlacementVC() {
        let modelPlacementVC = ModelPlacementViewController(
            roomCorners: roomCorners,
            floorHeight: floorHeight,
            ceilingHeight: ceilingHeight
        )
        navigationController?.pushViewController(modelPlacementVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Performance Optimization
    func optimizeForPerformance() {
        // Reduce rendering quality for better performance
        sceneView.antialiasingMode = .none
        
        // Disable unnecessary features
        sceneView.automaticallyUpdatesLighting = false
        
        // Reduce the number of objects in the scene when possible
        // This is especially important for complex 3D models
        
        // Note: renderingAPI is read-only, so we can't set it directly
        // Instead, use other performance optimization techniques
        
        // Reduce scene complexity
        sceneView.isJitteringEnabled = false
        
        // Optimize physics simulation
        sceneView.scene.physicsWorld.speed = 0.5
        
        // Disable default lighting if you're adding your own
        sceneView.autoenablesDefaultLighting = false
        
        // Set a reasonable debug options
        #if DEBUG
        sceneView.debugOptions = []
        #endif
    }
}

// MARK: - Extensions
extension SCNGeometry {
    static func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
}
