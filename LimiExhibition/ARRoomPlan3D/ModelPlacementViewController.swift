import UIKit
import ARKit
import SceneKit
import RealityKit

// MARK: - ModelCell
// Move ModelCell class to file scope (outside of any other class)
class ModelCell: UICollectionViewCell {
    private let label = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup cell appearance
        contentView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // Setup image view
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 30)
        contentView.addSubview(imageView)
        
        // Setup label
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.frame = CGRect(x: 0, y: frame.height - 25, width: frame.width, height: 20)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with modelName: String) {
        label.text = modelName
        
        // Set a placeholder image for the model
        imageView.backgroundColor = .lightGray
        
        // Create a simple icon representing a 3D model
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
        let image = renderer.image { ctx in
            let rect = CGRect(x: 10, y: 10, width: 40, height: 40)
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.stroke(rect)
            
            // Draw a simple cube
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 10, y: 10))
            path.addLine(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: 60, y: 0))
            path.addLine(to: CGPoint(x: 50, y: 10))
            path.move(to: CGPoint(x: 50, y: 10))
            path.addLine(to: CGPoint(x: 50, y: 50))
            path.move(to: CGPoint(x: 60, y: 0))
            path.addLine(to: CGPoint(x: 60, y: 40))
            path.addLine(to: CGPoint(x: 50, y: 50))
            
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.7) : UIColor.darkGray.withAlphaComponent(0.7)
        }
    }
}

// Protocol for ModelPlacementViewController
protocol ModelPlacementDelegate: AnyObject {
    func modelPlacementCompleted()
    func modelPlacementCancelled()
}

class ModelPlacementViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    private var sceneView: ARSCNView!
    private let roomCorners: [SCNVector3]
    private let floorHeight: Float
    private let ceilingHeight: Float
    
    private var selectedModelName: String?
    private var placementNode: SCNNode?
    
    // Available 3D models
    private let availableModels = [
        "WallLight",
        "CeilingPendant",
        "FloorLamps",
        "MultiplePendants",
        "texturedlight"
    ]
    
    // UI Elements
    private var modelSelectionCollectionView: UICollectionView!
    private var placeButton: UIButton!
    private var resetButton: UIButton!
    private var instructionLabel: UILabel!
    
    // MARK: - Initialization
    init(roomCorners: [SCNVector3], floorHeight: Float, ceilingHeight: Float) {
        self.roomCorners = roomCorners
        self.floorHeight = floorHeight
        self.ceilingHeight = ceilingHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARScene()
        setupUI()
        createRoomModel()
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
        instructionLabel.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 60)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .white
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 10
        instructionLabel.layer.masksToBounds = true
        instructionLabel.text = "Select a model and tap in the room to place it"
        view.addSubview(instructionLabel)
        
        // Setup collection view for model selection
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        
        modelSelectionCollectionView = UICollectionView(frame: CGRect(x: 0, y: view.bounds.height - 150, width: view.bounds.width, height: 120), collectionViewLayout: layout)
        modelSelectionCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        modelSelectionCollectionView.register(ModelCell.self, forCellWithReuseIdentifier: "ModelCell")
        // Fix: Explicitly set self as the dataSource and delegate
        modelSelectionCollectionView.dataSource = self
        modelSelectionCollectionView.delegate = self
        view.addSubview(modelSelectionCollectionView)
        
        // Place button
        placeButton = UIButton(type: .system)
        placeButton.frame = CGRect(x: view.bounds.width - 170, y: view.bounds.height - 200, width: 150, height: 40)
        placeButton.setTitle("Place Model", for: .normal)
        placeButton.backgroundColor = .systemGreen
        placeButton.setTitleColor(.white, for: .normal)
        placeButton.layer.cornerRadius = 10
        placeButton.addTarget(self, action: #selector(placeButtonTapped), for: .touchUpInside)
        placeButton.isHidden = true
        view.addSubview(placeButton)
        
        // Reset button
        resetButton = UIButton(type: .system)
        resetButton.frame = CGRect(x: 20, y: view.bounds.height - 200, width: 150, height: 40)
        resetButton.setTitle("Reset Scene", for: .normal)
        resetButton.backgroundColor = .systemRed
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 10
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        view.addSubview(resetButton)
    }
    
    // MARK: - Room Model Creation
    private func createRoomModel() {
        // Create floor
        createFloor()
        
        // Create ceiling
        createCeiling()
        
        // Create walls
        createWalls()
    }
    
    private func createFloor() {
        // Create a custom shape for the floor based on the 4 corners
        let floorNode = createPolygonNode(
            points: roomCorners,
            height: floorHeight,
            color: UIColor.gray.withAlphaComponent(0.3),
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
            color: UIColor.white.withAlphaComponent(0.3),
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
            let wallNode = createWallNode(vertices: vertices, color: UIColor.lightGray.withAlphaComponent(0.3))
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
    
    // MARK: - 3D Model Loading and Placement
    private func loadModel(named modelName: String) {
        // Remove any existing placement node
        placementNode?.removeFromParentNode()
        
        // Load the model - fix the withExtension parameter
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "art.scnassets") else {
            print("Failed to find model: \(modelName)")
            return
        }
        
        // Create a placement node
        placementNode = SCNNode()
        
        // Load the USDZ model
        do {
            let scene = try SCNScene(url: url, options: nil)
            
            // Get the main node from the loaded scene
            if let modelNode = scene.rootNode.childNodes.first {
                // Add the model to the placement node
                placementNode?.addChildNode(modelNode)
                
                // Add the placement node to the scene
                sceneView.scene.rootNode.addChildNode(placementNode!)
                
                // Position the model at the center of the screen initially
                updatePlacementPosition()
                
                // Show the place button
                placeButton.isHidden = false
            }
        } catch {
            print("Error loading model: \(error.localizedDescription)")
        }
    }
    
    private func updatePlacementPosition() {
        // Get the center of the screen
        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        
        // Perform hit test to find real-world position
        if let hitTestResult = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .estimatedVerticalPlane]).first {
            let position = SCNVector3(
                hitTestResult.worldTransform.columns.3.x,
                hitTestResult.worldTransform.columns.3.y,
                hitTestResult.worldTransform.columns.3.z
            )
            
            // Update the position of the placement node
            placementNode?.position = position
        }
    }
    
    private func placeModel() {
        guard let placementNode = placementNode else { return }
        
        // Create a new node for the final placement
        let finalNode = placementNode.clone()
        
        // Add the final node to the scene
        sceneView.scene.rootNode.addChildNode(finalNode)
        
        // Reset the placement node
        self.placementNode?.removeFromParentNode()
        self.placementNode = nil
        
        // Hide the place button
        placeButton.isHidden = true
        
        // Deselect the model in the collection view
        if let selectedIndexPath = modelSelectionCollectionView.indexPathsForSelectedItems?.first {
            modelSelectionCollectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
        selectedModelName = nil
    }
    
    // MARK: - Action Methods
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Get the location of the tap in the AR scene view
        let location = gestureRecognizer.location(in: sceneView)
        
        // Perform hit test to find real-world position
        if let hitTestResult = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .estimatedVerticalPlane]).first {
            let position = SCNVector3(
                hitTestResult.worldTransform.columns.3.x,
                hitTestResult.worldTransform.columns.3.y,
                hitTestResult.worldTransform.columns.3.z
            )
            
            // If we have a placement node, update its position
            if let placementNode = placementNode {
                placementNode.position = position
            }
        }
    }
    
    @objc private func placeButtonTapped() {
        placeModel()
    }
    
    @objc private func resetButtonTapped() {
        // Remove all models except the room structure
        sceneView.scene.rootNode.childNodes.forEach { node in
            // Fix: Properly check if the node is part of the room structure
            let isRoomPart = node.name?.contains("room") ?? false
            if node != placementNode && !isRoomPart {
                node.removeFromParentNode()
            }
        }
        
        // Reset the placement node
        placementNode?.removeFromParentNode()
        placementNode = nil
        
        // Hide the place button
        placeButton.isHidden = true
        
        // Deselect the model in the collection view
        if let selectedIndexPath = modelSelectionCollectionView.indexPathsForSelectedItems?.first {
            modelSelectionCollectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
        selectedModelName = nil
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update the position of the placement node if it exists
        if placementNode != nil {
            updatePlacementPosition()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModelCell", for: indexPath) as! ModelCell
        cell.configure(with: availableModels[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedModelName = availableModels[indexPath.item]
        loadModel(named: selectedModelName!)
    }
    weak var delegate: ModelPlacementDelegate?

    private func setupDoneButton() {
        let doneButton = UIButton(type: .system)
        doneButton.frame = CGRect(x: view.bounds.width - 100, y: 40, width: 80, height: 40)
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = .systemGreen
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 10
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
    }

    @objc private func doneButtonTapped() {
        delegate?.modelPlacementCompleted()
    }

    // Update resetButtonTapped to include a cancel option
    @objc private func cancelButtonTapped() {
        delegate?.modelPlacementCancelled()
    }
}
