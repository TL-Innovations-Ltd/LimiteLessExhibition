//import UIKit
//import ARKit
//import SceneKit
//import RealityKit
//
//// MARK: - ModelCell
//class ModelCell: UICollectionViewCell {
//    private let label = UILabel()
//    private let imageView = UIImageView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // Setup cell appearance
//        contentView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
//        contentView.layer.cornerRadius = 10
//        contentView.layer.masksToBounds = true
//        
//        // Setup image view
//        imageView.contentMode = .scaleAspectFit
//        imageView.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 30)
//        contentView.addSubview(imageView)
//        
//        // Setup label
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 12)
//        label.frame = CGRect(x: 0, y: frame.height - 25, width: frame.width, height: 20)
//        contentView.addSubview(label)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with modelName: String) {
//        label.text = modelName
//        
//        // Set a placeholder image for the model
//        imageView.backgroundColor = .lightGray
//        
//        // Create a simple icon representing a 3D model
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
//        let image = renderer.image { ctx in
//            let rect = CGRect(x: 10, y: 10, width: 40, height: 40)
//            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
//            ctx.cgContext.setLineWidth(2)
//            ctx.cgContext.stroke(rect)
//            
//            // Draw a simple cube
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: 10, y: 10))
//            path.addLine(to: CGPoint(x: 20, y: 0))
//            path.addLine(to: CGPoint(x: 60, y: 0))
//            path.addLine(to: CGPoint(x: 50, y: 10))
//            path.move(to: CGPoint(x: 50, y: 10))
//            path.addLine(to: CGPoint(x: 50, y: 50))
//            path.move(to: CGPoint(x: 60, y: 0))
//            path.addLine(to: CGPoint(x: 60, y: 40))
//            path.addLine(to: CGPoint(x: 50, y: 50))
//            
//            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
//            ctx.cgContext.addPath(path.cgPath)
//            ctx.cgContext.strokePath()
//        }
//        
//        imageView.image = image
//    }
//    
//    override var isSelected: Bool {
//        didSet {
//            contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.7) : UIColor.darkGray.withAlphaComponent(0.7)
//        }
//    }
//}
//
//// Protocol for ModelPlacementViewController
//protocol ModelPlacementDelegate: AnyObject {
//    func modelPlacementCompleted()
//    func modelPlacementCancelled()
//}
//
//class ModelPlacementViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    // MARK: - Properties
//    private var sceneView: ARSCNView!
//    private let roomCorners: [SCNVector3]
//    private let floorHeight: Float
//    private let ceilingHeight: Float
//
//    private var selectedModelName: String?
//    private var placementNode: SCNNode?
//    private var selectedNode: SCNNode?
//    private var placedModels: [SCNNode] = []
//
//    // For device-specific adjustments
//    private var isSmallDevice: Bool {
//        let screenHeight = UIScreen.main.bounds.height
//        return screenHeight <= 812 // iPhone 12 mini and smaller devices
//    }
//
//    // Available 3D models - simplified list with generic names that will work with placeholders
//    private let availableModels = [
//        "WallLight",
//        "CeilingLight",
//        "FloorLamp",
//        "TableLamp",
//        "PendantLight"
//    ]
//    
//    // UI Elements
//    private var modelSelectionCollectionView: UICollectionView!
//    private var placeButton: UIButton!
//    private var resetButton: UIButton!
//    private var doneButton: UIButton!
//    private var instructionLabel: UILabel!
//    private var rotationSlider: UISlider!
//    private var scaleSlider: UISlider!
//    private var targetImageView: UIImageView!
//    private var controlPanel: UIView!
//    private var deleteButton: UIButton!
//    private var duplicateButton: UIButton!
//    
//    weak var delegate: ModelPlacementDelegate?
//    
//    // MARK: - Initialization
//    init(roomCorners: [SCNVector3], floorHeight: Float, ceilingHeight: Float) {
//        self.roomCorners = roomCorners
//        self.floorHeight = floorHeight
//        self.ceilingHeight = ceilingHeight
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupARScene()
//        setupUI()
//        setupTargetImageView()
//        createRoomModel()
//        setupGestureRecognizers()
//        setupDoneButton()
//        setupControlPanel()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // Create AR configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        
//        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
//            configuration.frameSemantics = .sceneDepth
//        }
//        
//        // Run the view's session
//        sceneView.session.run(configuration)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Pause the view's session
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
//        sceneView.showsStatistics = false // Hide statistics in production
//        sceneView.autoenablesDefaultLighting = true
//        view.addSubview(sceneView)
//        
//        // Add tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        sceneView.addGestureRecognizer(tapGesture)
//    }
//    
//    private func setupUI() {
//        // Instruction label
//        instructionLabel = UILabel()
//        instructionLabel.textAlignment = .center
//        instructionLabel.numberOfLines = 0
//        instructionLabel.textColor = .white
//        instructionLabel.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 18, weight: .medium)
//        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        instructionLabel.layer.cornerRadius = 10
//        instructionLabel.layer.masksToBounds = true
//        instructionLabel.text = "Select a model and tap in the room to place it"
//        view.addSubview(instructionLabel)
//        
//        // Setup collection view for model selection
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: isSmallDevice ? 80 : 100, height: isSmallDevice ? 80 : 100)
//        layout.minimumLineSpacing = 10
//        
//        modelSelectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        modelSelectionCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        modelSelectionCollectionView.register(ModelCell.self, forCellWithReuseIdentifier: "ModelCell")
//        modelSelectionCollectionView.dataSource = self
//        modelSelectionCollectionView.delegate = self
//        modelSelectionCollectionView.showsHorizontalScrollIndicator = false
//        view.addSubview(modelSelectionCollectionView)
//        
//        // Place button
//        placeButton = UIButton(type: .system)
//        placeButton.setTitle("Place Model", for: .normal)
//        placeButton.backgroundColor = .systemGreen
//        placeButton.setTitleColor(.white, for: .normal)
//        placeButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 18, weight: .semibold)
//        placeButton.layer.cornerRadius = 10
//        placeButton.addTarget(self, action: #selector(placeButtonTapped), for: .touchUpInside)
//        placeButton.isHidden = true
//        view.addSubview(placeButton)
//        
//        // Reset button
//        resetButton = UIButton(type: .system)
//        resetButton.setTitle("Reset Scene", for: .normal)
//        resetButton.backgroundColor = .systemRed
//        resetButton.setTitleColor(.white, for: .normal)
//        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 18, weight: .semibold)
//        resetButton.layer.cornerRadius = 10
//        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
//        view.addSubview(resetButton)
//        
//        // Rotation slider
//        rotationSlider = UISlider()
//        rotationSlider.minimumValue = 0
//        rotationSlider.maximumValue = Float.pi * 2
//        rotationSlider.value = 0
//        rotationSlider.addTarget(self, action: #selector(rotationSliderChanged(_:)), for: .valueChanged)
//        rotationSlider.isHidden = true
//        view.addSubview(rotationSlider)
//        
//        // Scale slider
//        scaleSlider = UISlider()
//        scaleSlider.minimumValue = 0.5
//        scaleSlider.maximumValue = 2.0
//        scaleSlider.value = 1.0
//        scaleSlider.addTarget(self, action: #selector(scaleSliderChanged(_:)), for: .valueChanged)
//        scaleSlider.isHidden = true
//        view.addSubview(scaleSlider)
//        
//        // Position UI elements based on device size
//        updateUIForCurrentDevice()
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
//        targetImageView.isHidden = true // Initially hidden
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
//    private func setupDoneButton() {
//        doneButton = UIButton(type: .system)
//        doneButton.setTitle("Done", for: .normal)
//        doneButton.backgroundColor = .systemGreen
//        doneButton.setTitleColor(.white, for: .normal)
//        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 14 : 16, weight: .medium)
//        doneButton.layer.cornerRadius = 10
//        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
//        view.addSubview(doneButton)
//        
//        // Position the done button
//        let topPadding: CGFloat = isSmallDevice ? 30 : 40
//        let buttonWidth: CGFloat = isSmallDevice ? 70 : 80
//        let buttonHeight: CGFloat = isSmallDevice ? 30 : 40
//        doneButton.frame = CGRect(x: view.bounds.width - buttonWidth - 20, y: topPadding, width: buttonWidth, height: buttonHeight)
//    }
//    
//    private func setupControlPanel() {
//        // Create a control panel for selected objects
//        controlPanel = UIView()
//        controlPanel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        controlPanel.layer.cornerRadius = 10
//        controlPanel.isHidden = true
//        view.addSubview(controlPanel)
//        
//        // Delete button
//        deleteButton = UIButton(type: .system)
//        deleteButton.setTitle("Delete", for: .normal)
//        deleteButton.setTitleColor(.white, for: .normal)
//        deleteButton.backgroundColor = .systemRed
//        deleteButton.layer.cornerRadius = 8
//        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
//        controlPanel.addSubview(deleteButton)
//        
//        // Duplicate button
//        duplicateButton = UIButton(type: .system)
//        duplicateButton.setTitle("Duplicate", for: .normal)
//        duplicateButton.setTitleColor(.white, for: .normal)
//        duplicateButton.backgroundColor = .systemBlue
//        duplicateButton.layer.cornerRadius = 8
//        duplicateButton.addTarget(self, action: #selector(duplicateButtonTapped), for: .touchUpInside)
//        controlPanel.addSubview(duplicateButton)
//        
//        // Position the control panel
//        let panelWidth: CGFloat = 200
//        let panelHeight: CGFloat = 100
//        let buttonHeight: CGFloat = 40
//        let buttonSpacing: CGFloat = 10
//        
//        controlPanel.frame = CGRect(
//            x: (view.bounds.width - panelWidth) / 2,
//            y: view.bounds.height - 250,
//            width: panelWidth,
//            height: panelHeight
//        )
//        
//        deleteButton.frame = CGRect(
//            x: 10,
//            y: 10,
//            width: panelWidth - 20,
//            height: buttonHeight
//        )
//        
//        duplicateButton.frame = CGRect(
//            x: 10,
//            y: deleteButton.frame.maxY + buttonSpacing,
//            width: panelWidth - 20,
//            height: buttonHeight
//        )
//    }
//    
//    private func setupGestureRecognizers() {
//        // Add pinch gesture for scaling
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        sceneView.addGestureRecognizer(pinchGesture)
//        
//        // Add rotation gesture
//        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
//        sceneView.addGestureRecognizer(rotationGesture)
//        
//        // Add pan gesture for moving objects
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.maximumNumberOfTouches = 1
//        sceneView.addGestureRecognizer(panGesture)
//        
//        // Add long press gesture for additional options
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        longPressGesture.minimumPressDuration = 0.8
//        sceneView.addGestureRecognizer(longPressGesture)
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
//        // Instruction label
//        let labelHeight: CGFloat = isSmallDevice ? 60 : 70
//        instructionLabel.frame = CGRect(
//            x: horizontalPadding,
//            y: topPadding + (isSmallDevice ? 30 : 40),
//            width: view.bounds.width - (horizontalPadding * 2),
//            height: labelHeight
//        )
//        
//        // Collection view
//        let collectionViewHeight: CGFloat = isSmallDevice ? 100 : 120
//        modelSelectionCollectionView.frame = CGRect(
//            x: 0,
//            y: view.bounds.height - bottomPadding - collectionViewHeight,
//            width: view.bounds.width,
//            height: collectionViewHeight
//        )
//        
//        // Place button
//        placeButton.frame = CGRect(
//            x: view.bounds.width - buttonWidth - horizontalPadding,
//            y: view.bounds.height - bottomPadding - buttonHeight - collectionViewHeight - 10,
//            width: buttonWidth,
//            height: buttonHeight
//        )
//        
//        // Reset button
//        resetButton.frame = CGRect(
//            x: horizontalPadding,
//            y: view.bounds.height - bottomPadding - buttonHeight - collectionViewHeight - 10,
//            width: buttonWidth,
//            height: buttonHeight
//        )
//        
//        // Rotation slider
//        let sliderWidth: CGFloat = view.bounds.width - (horizontalPadding * 2)
//        let sliderHeight: CGFloat = 30
//        let sliderSpacing: CGFloat = 10
//        
//        rotationSlider.frame = CGRect(
//            x: horizontalPadding,
//            y: view.bounds.height - bottomPadding - collectionViewHeight - buttonHeight - sliderHeight - sliderSpacing - 20,
//            width: sliderWidth,
//            height: sliderHeight
//        )
//        
//        // Scale slider
//        scaleSlider.frame = CGRect(
//            x: horizontalPadding,
//            y: rotationSlider.frame.minY - sliderHeight - sliderSpacing,
//            width: sliderWidth,
//            height: sliderHeight
//        )
//        
//        // Update done button position
//        let doneButtonWidth: CGFloat = isSmallDevice ? 70 : 80
//        let doneButtonHeight: CGFloat = isSmallDevice ? 30 : 40
//        doneButton.frame = CGRect(
//            x: view.bounds.width - doneButtonWidth - 20,
//            y: topPadding,
//            width: doneButtonWidth,
//            height: doneButtonHeight
//        )
//        
//        // Update control panel position
//        let panelWidth: CGFloat = 200
//        let panelHeight: CGFloat = 100
//        
//        controlPanel.frame = CGRect(
//            x: (view.bounds.width - panelWidth) / 2,
//            y: view.bounds.height - 250,
//            width: panelWidth,
//            height: panelHeight
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
//    // MARK: - Room Model Creation
//    private func createRoomModel() {
//        // Create floor
//        createFloor()
//        
//        // Create ceiling
//        createCeiling()
//        
//        // Create walls
//        createWalls()
//        
//        // Add ambient lighting to the room
//        addAmbientLighting()
//        
//        // Show welcome message
//        showWelcomeMessage()
//    }
//    
//    private func showWelcomeMessage() {
//        let alert = UIAlertController(
//            title: "Room Created Successfully",
//            message: "Your room has been created with dimensions:\nWidth: \(String(format: "%.2f", getRoomWidth())) m\nLength: \(String(format: "%.2f", getRoomLength())) m\nHeight: \(String(format: "%.2f", ceilingHeight - floorHeight)) m\n\nSelect a model from the bottom menu to place it in your room.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Start Placing Models", style: .default))
//        present(alert, animated: true)
//    }
//    
//    private func getRoomWidth() -> Float {
//        // Calculate approximate room width
//        if roomCorners.count >= 2 {
//            let dx = roomCorners[0].x - roomCorners[1].x
//            let dz = roomCorners[0].z - roomCorners[1].z
//            return sqrt(dx * dx + dz * dz)
//        }
//        return 0
//    }
//    
//    private func getRoomLength() -> Float {
//        // Calculate approximate room length
//        if roomCorners.count >= 4 {
//            let dx = roomCorners[1].x - roomCorners[2].x
//            let dz = roomCorners[1].z - roomCorners[2].z
//            return sqrt(dx * dx + dz * dz)
//        }
//        return 0
//    }
//    
//    private func createFloor() {
//        // Create a custom shape for the floor based on the 4 corners
//        let floorNode = createPolygonNode(
//            points: roomCorners,
//            height: floorHeight,
//            color: UIColor.gray.withAlphaComponent(0.3),
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
//            color: UIColor.white.withAlphaComponent(0.3),
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
//            let wallNode = createWallNode(vertices: vertices, color: UIColor.lightGray.withAlphaComponent(0.3))
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
//    // MARK: - 3D Model Loading and Placement
//    private func loadModel(named modelName: String) {
//        // Remove any existing placement node
//        placementNode?.removeFromParentNode()
//        
//        // Create a placement node first
//        placementNode = SCNNode()
//        
//        // Try to load the model from different possible locations
//        var modelURL: URL?
//        
//        // First try the art.scnassets directory
//        if let url = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "art.scnassets") {
//            modelURL = url
//        }
//        // Then try without subdirectory
//        else if let url = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
//            modelURL = url
//        }
//        // Try with .scn extension in art.scnassets
//        else if let url = Bundle.main.url(forResource: modelName, withExtension: "scn", subdirectory: "art.scnassets") {
//            modelURL = url
//        }
//        // Try with .scn extension without subdirectory
//        else if let url = Bundle.main.url(forResource: modelName, withExtension: "scn") {
//            modelURL = url
//        }
//        
//        // If we couldn't find the model, create a placeholder
//        if modelURL == nil {
//            print("Failed to find model: \(modelName). Creating placeholder.")
//            createPlaceholderModel(named: modelName)
//            return
//        }
//        
//        // Load the model
//        do {
//            let scene = try SCNScene(url: modelURL!, options: nil)
//            
//            // Get the main node from the loaded scene
//            if let modelNode = scene.rootNode.childNodes.first {
//                // Add the model to the placement node
//                placementNode?.addChildNode(modelNode)
//                
//                // Add the placement node to the scene
//                sceneView.scene.rootNode.addChildNode(placementNode!)
//                
//                // Position the model at the center of the screen initially
//                updatePlacementPosition()
//                
//                // Show the place button and sliders
//                placeButton.isHidden = false
//                rotationSlider.isHidden = false
//                scaleSlider.isHidden = false
//                
//                // Show target for better aiming
//                targetImageView.isHidden = false
//                
//                // Update instruction
//                instructionLabel.text = "Position the model and tap 'Place Model' when ready"
//                
//                // Provide haptic feedback
//                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
//                feedbackGenerator.impactOccurred()
//            } else {
//                print("Model loaded but no nodes found in: \(modelName)")
//                createPlaceholderModel(named: modelName)
//            }
//        } catch {
//            print("Error loading model: \(error.localizedDescription)")
//            createPlaceholderModel(named: modelName)
//        }
//    }
//
//    // Add a method to create placeholder models when the actual model file is missing
//    private func createPlaceholderModel(named modelName: String) {
//        // Create a simple placeholder geometry based on the model type
//        var geometry: SCNGeometry
//        var scale: SCNVector3
//        
//        if modelName.lowercased().contains("light") || modelName.lowercased().contains("lamp") {
//            // For lights, create a simple light bulb shape
//            geometry = SCNSphere(radius: 0.05)
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.yellow
//            material.emission.contents = UIColor.yellow.withAlphaComponent(0.5)
//            geometry.materials = [material]
//            
//            // Add a light to make it glow
//            let light = SCNLight()
//            light.type = .omni
//            light.color = UIColor.yellow
//            light.intensity = 500
//            
//            let lightNode = SCNNode()
//            lightNode.light = light
//            placementNode?.addChildNode(lightNode)
//            
//            scale = SCNVector3(1, 1, 1)
//        }
//        else if modelName.lowercased().contains("pendant") {
//            // For pendant lights, create a hanging light
//            let bulb = SCNSphere(radius: 0.05)
//            let bulbMaterial = SCNMaterial()
//            bulbMaterial.diffuse.contents = UIColor.yellow
//            bulbMaterial.emission.contents = UIColor.yellow.withAlphaComponent(0.5)
//            bulb.materials = [bulbMaterial]
//            
//            let bulbNode = SCNNode(geometry: bulb)
//            bulbNode.position = SCNVector3(0, -0.1, 0)
//            
//            // Create a cylinder for the cord
//            let cord = SCNCylinder(radius: 0.005, height: 0.2)
//            let cordMaterial = SCNMaterial()
//            cordMaterial.diffuse.contents = UIColor.black
//            cord.materials = [cordMaterial]
//            
//            let cordNode = SCNNode(geometry: cord)
//            cordNode.position = SCNVector3(0, 0, 0)
//            
//            // Add a light
//            let light = SCNLight()
//            light.type = .omni
//            light.color = UIColor.yellow
//            light.intensity = 500
//            bulbNode.light = light
//            
//            placementNode?.addChildNode(cordNode)
//            placementNode?.addChildNode(bulbNode)
//            
//            geometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
//            scale = SCNVector3(1, 1, 1)
//        }
//        else {
//            // Default placeholder is a cube
//            geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//            let material = SCNMaterial()
//            material.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
//            geometry.materials = [material]
//            scale = SCNVector3(1, 1, 1)
//        }
//        
//        // Create a node with the placeholder geometry
//        let placeholderNode = SCNNode(geometry: geometry)
//        placeholderNode.scale = scale
//        
//        // Add a text label with the model name
//        let text = SCNText(string: modelName, extrusionDepth: 0.01)
//        text.font = UIFont.systemFont(ofSize: 0.5)
//        text.firstMaterial?.diffuse.contents = UIColor.white
//        
//        let textNode = SCNNode(geometry: text)
//        textNode.scale = SCNVector3(0.02, 0.02, 0.02)
//        textNode.position = SCNVector3(0, 0.1, 0)
//        
//        // Make text always face the camera
//        let billboardConstraint = SCNBillboardConstraint()
//        textNode.constraints = [billboardConstraint]
//        
//        // Add nodes to the placement node
//        placementNode?.addChildNode(placeholderNode)
//        placementNode?.addChildNode(textNode)
//        
//        // Add the placement node to the scene
//        sceneView.scene.rootNode.addChildNode(placementNode!)
//        
//        // Position the model at the center of the screen initially
//        updatePlacementPosition()
//        
//        // Show the place button and sliders
//        placeButton.isHidden = false
//        rotationSlider.isHidden = false
//        scaleSlider.isHidden = false
//        
//        // Show target for better aiming
//        targetImageView.isHidden = false
//        
//        // Update instruction with warning about placeholder
//        instructionLabel.text = "Using placeholder for \(modelName). Position and tap 'Place Model'"
//        
//        // Show alert about missing model
//        showAlert(title: "Model Not Found", message: "Using a placeholder for \(modelName). The actual model file could not be found.")
//    }
//    
//    private func updatePlacementPosition() {
//        // Get the center of the screen
//        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
//        
//        // Perform hit test to find real-world position
//        let hitTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .estimatedVerticalPlane])
//        
//        if let bestResult = hitTestResults.first {
//            let position = SCNVector3(
//                bestResult.worldTransform.columns.3.x,
//                bestResult.worldTransform.columns.3.y,
//                bestResult.worldTransform.columns.3.z
//            )
//            
//            // Update the position of the placement node
//            placementNode?.position = position
//            
//            // Check for collisions with room elements
//            if isCollidingWithRoom(node: placementNode) {
//                // Visual feedback for collision
//                highlightCollision(isColliding: true)
//            } else {
//                highlightCollision(isColliding: false)
//            }
//        }
//    }
//    
//    private func isCollidingWithRoom(node: SCNNode?) -> Bool {
//        guard let node = node else { return false }
//        
//        // Get all room elements
//        let roomElements = sceneView.scene.rootNode.childNodes.filter { $0.name?.contains("room") ?? false }
//        
//        // Check for collisions
//        for roomElement in roomElements {
//            // Get bounding boxes
//            let nodeBoundingBox = node.boundingBox
//            let roomElementBoundingBox = roomElement.boundingBox
//            
//            // Convert to world coordinates
//            let nodeMin = node.convertPosition(SCNVector3(nodeBoundingBox.min.x, nodeBoundingBox.min.y, nodeBoundingBox.min.z), to: nil)
//            let nodeMax = node.convertPosition(SCNVector3(nodeBoundingBox.max.x, nodeBoundingBox.max.y, nodeBoundingBox.max.z), to: nil)
//            
//            let roomMin = roomElement.convertPosition(SCNVector3(roomElementBoundingBox.min.x, roomElementBoundingBox.min.y, roomElementBoundingBox.min.z), to: nil)
//            let roomMax = roomElement.convertPosition(SCNVector3(roomElementBoundingBox.max.x, roomElementBoundingBox.max.y, roomElementBoundingBox.max.z), to: nil)
//            
//            // Check for intersection
//            if (nodeMin.x <= roomMax.x && nodeMax.x >= roomMin.x) &&
//                (nodeMin.y <= roomMax.y && nodeMax.y >= roomMin.y) &&
//                (nodeMin.z <= roomMax.z && nodeMax.z >= roomMin.z) {
//                return true
//            }
//        }
//        
//        return false
//    }
//    
//    private func highlightCollision(isColliding: Bool) {
//        // Visual feedback for collision
//        if isColliding {
//            // Red tint for collision
//            placementNode?.childNodes.forEach { node in
//                node.geometry?.materials.forEach { material in
//                    material.emission.contents = UIColor.red.withAlphaComponent(0.3)
//                }
//            }
//            
//            // Update target color
//            targetImageView.tintColor = .red
//        } else {
//            // Normal appearance
//            placementNode?.childNodes.forEach { node in
//                node.geometry?.materials.forEach { material in
//                    material.emission.contents = nil
//                }
//            }
//            
//            // Update target color
//            targetImageView.tintColor = .green
//        }
//    }
//    
//    private func placeModel() {
//        guard let placementNode = placementNode else { return }
//        
//        // Check for collisions before placing
//        if isCollidingWithRoom(node: placementNode) {
//            showAlert(title: "Cannot Place Model", message: "The model is colliding with the room. Please reposition it.")
//            return
//        }
//        
//        // Create a new node for the final placement
//        let finalNode = placementNode.clone()
//        finalNode.name = "placed_model_\(UUID().uuidString)"
//        
//        // Add the final node to the scene and track it
//        sceneView.scene.rootNode.addChildNode(finalNode)
//        placedModels.append(finalNode)
//        
//        // Reset the placement node
//        self.placementNode?.removeFromParentNode()
//        self.placementNode = nil
//        
//        // Hide the place button, sliders, and target
//        placeButton.isHidden = true
//        rotationSlider.isHidden = true
//        scaleSlider.isHidden = true
//        targetImageView.isHidden = true
//        
//        // Deselect the model in the collection view
//        if let selectedIndexPath = modelSelectionCollectionView.indexPathsForSelectedItems?.first {
//            modelSelectionCollectionView.deselectItem(at: selectedIndexPath, animated: true)
//        }
//        selectedModelName = nil
//        
//        // Update instruction
//        instructionLabel.text = "Model placed successfully! Select another model or tap an existing model to edit it."
//        
//        // Provide haptic feedback
//        let feedbackGenerator = UINotificationFeedbackGenerator()
//        feedbackGenerator.notificationOccurred(.success)
//    }
//    
//    // MARK: - Action Methods
//    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//        // Get the location of the tap in the AR scene view
//        let location = gestureRecognizer.location(in: sceneView)
//        
//        if placementNode != nil {
//            // If we're in placement mode, update the position
//            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .estimatedVerticalPlane])
//            
//            if let bestResult = hitTestResults.first {
//                let position = SCNVector3(
//                    bestResult.worldTransform.columns.3.x,
//                    bestResult.worldTransform.columns.3.y,
//                    bestResult.worldTransform.columns.3.z
//                )
//                
//                placementNode?.position = position
//                
//                // Check for collisions
//                if isCollidingWithRoom(node: placementNode) {
//                    highlightCollision(isColliding: true)
//                } else {
//                    highlightCollision(isColliding: false)
//                }
//            }
//        } else {
//            // If we're not in placement mode, check if we tapped on an existing model
//            let hitResults = sceneView.hitTest(location, options: nil)
//            
//            if let result = hitResults.first {
//                // Find the top-level parent that represents a placed model
//                var currentNode = result.node
//                while let parent = currentNode.parent, parent != sceneView.scene.rootNode {
//                    if parent.name?.contains("placed_model") ?? false {
//                        currentNode = parent
//                        break
//                    }
//                    currentNode = parent
//                }
//                
//                // If we tapped on a placed model
//                if currentNode.name?.contains("placed_model") ?? false {
//                    // Deselect previous node
//                    selectedNode?.childNodes.forEach { node in
//                        node.geometry?.materials.forEach { material in
//                            material.emission.contents = nil
//                        }
//                    }
//                    
//                    // Select new node
//                    selectedNode = currentNode
//                    selectedNode?.childNodes.forEach { node in
//                        node.geometry?.materials.forEach { material in
//                            material.emission.contents = UIColor.green.withAlphaComponent(0.3)
//                        }
//                    }
//                    
//                    // Show rotation and scale sliders
//                    rotationSlider.isHidden = false
//                    scaleSlider.isHidden = false
//                    
//                    // Show control panel
//                    controlPanel.isHidden = false
//                    
//                    // Update slider values to match the selected node
//                    rotationSlider.value = Float(selectedNode?.eulerAngles.y ?? 0)
//                    scaleSlider.value = Float(selectedNode?.scale.x ?? 1.0)
//                    
//                    // Update instruction
//                    instructionLabel.text = "Model selected. Use sliders to adjust rotation and scale, or drag to move."
//                    
//                    // Provide haptic feedback
//                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
//                    feedbackGenerator.impactOccurred()
//                } else {
//                    // Deselect if we tapped elsewhere
//                    selectedNode?.childNodes.forEach { node in
//                        node.geometry?.materials.forEach { material in
//                            material.emission.contents = nil
//                        }
//                    }
//                    selectedNode = nil
//                    
//                    // Hide sliders and control panel
//                    rotationSlider.isHidden = true
//                    scaleSlider.isHidden = true
//                    controlPanel.isHidden = true
//                    
//                    // Update instruction
//                    instructionLabel.text = "Select a model from the bottom menu to place it in your room."
//                }
//            }
//        }
//    }
//    
//    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
//        if gestureRecognizer.state == .changed {
//            let scale = Float(gestureRecognizer.scale)
//            
//            if let node = selectedNode ?? placementNode {
//                // Apply scale, but limit it to reasonable values
//                let newScale = max(0.5, min(2.0, Float(node.scale.x) * scale))
//                node.scale = SCNVector3(newScale, newScale, newScale)
//                
//                // Update the slider to match
//                scaleSlider.value = newScale
//            }
//            
//            // Reset the gesture scale
//            gestureRecognizer.scale = 1.0
//        }
//    }
//    
//    @objc private func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
//        if gestureRecognizer.state == .changed {
//            let rotation = Float(gestureRecognizer.rotation)
//            
//            if let node = selectedNode ?? placementNode {
//                // Apply rotation around Y axis
//                node.eulerAngles.y += rotation
//                
//                // Update the slider to match
//                rotationSlider.value = node.eulerAngles.y.truncatingRemainder(dividingBy: Float.pi * 2)
//                if rotationSlider.value < 0 {
//                    rotationSlider.value += Float.pi * 2
//                }
//            }
//            
//            // Reset the gesture rotation
//            gestureRecognizer.rotation = 0
//        }
//    }
//    
//    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//        guard let selectedNode = selectedNode, placementNode == nil else { return }
//        
//        if gestureRecognizer.state == .changed {
//            // Perform hit test to find where to move the object
//            let location = gestureRecognizer.location(in: sceneView)
//            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
//            
//            if let result = hitTestResults.first {
//                let position = SCNVector3(
//                    result.worldTransform.columns.3.x,
//                    result.worldTransform.columns.3.y,
//                    result.worldTransform.columns.3.z
//                )
//                
//                // Move the node, but maintain its y position to keep it on the floor/surface
//                let currentY = selectedNode.position.y
//                selectedNode.position = SCNVector3(position.x, currentY, position.z)
//                
//                // Check for collisions
//                if isCollidingWithRoom(node: selectedNode) {
//                    // Visual feedback for collision
//                    selectedNode.childNodes.forEach { node in
//                        node.geometry?.materials.forEach { material in
//                            material.emission.contents = UIColor.red.withAlphaComponent(0.3)
//                        }
//                    }
//                } else {
//                    // Normal appearance
//                    selectedNode.childNodes.forEach { node in
//                        node.geometry?.materials.forEach { material in
//                            material.emission.contents = UIColor.green.withAlphaComponent(0.3)
//                        }
//                    }
//                }
//            }
//        }
//        
//        // Reset the gesture translation
//        gestureRecognizer.setTranslation(.zero, in: sceneView)
//    }
//    
//    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            // Get the location of the long press
//            let location = gestureRecognizer.location(in: sceneView)
//            
//            // Perform hit test to see if we long-pressed on a model
//            let hitResults = sceneView.hitTest(location, options: nil)
//            
//            if let result = hitResults.first {
//                // Find the top-level parent that represents a placed model
//                var currentNode = result.node
//                while let parent = currentNode.parent, parent != sceneView.scene.rootNode {
//                    if parent.name?.contains("placed_model") ?? false {
//                        currentNode = parent
//                        break
//                    }
//                    currentNode = parent
//                }
//                
//                // If we long-pressed on a placed model
//                if currentNode.name?.contains("placed_model") ?? false {
//                    // Select the node
//                    selectedNode = currentNode
//                    
//                    // Show control panel at the location of the long press
//                    let screenLocation = gestureRecognizer.location(in: view)
//                    controlPanel.center = CGPoint(x: screenLocation.x, y: screenLocation.y - 70) // Position above finger
//                    controlPanel.isHidden = false
//                    
//                    // Highlight the selected model
//                    selectedNode?.childNodes.forEach { node in
//                        node.geometry?.materials.forEach { material in
//                            material.emission.contents = UIColor.green.withAlphaComponent(0.3)
//                        }
//                    }
//                    
//                    // Provide haptic feedback
//                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
//                    feedbackGenerator.impactOccurred()
//                }
//            }
//        }
//    }
//    
//    @objc private func placeButtonTapped() {
//        placeModel()
//    }
//    
//    @objc private func resetButtonTapped() {
//        // Remove all models except the room structure
//        sceneView.scene.rootNode.childNodes.forEach { node in
//            let isRoomPart = node.name?.contains("room") ?? false
//            let isLight = node.name?.contains("light") ?? false
//            if node != placementNode && !isRoomPart && !isLight {
//                node.removeFromParentNode()
//            }
//        }
//        
//        // Clear placed models array
//        placedModels.removeAll()
//        
//        // Reset the placement node
//        placementNode?.removeFromParentNode()
//        placementNode = nil
//        
//        // Reset the selected node
//        selectedNode = nil
//        
//        // Hide the place button, sliders, and control panel
//        placeButton.isHidden = true
//        rotationSlider.isHidden = true
//        scaleSlider.isHidden = true
//        controlPanel.isHidden = true
//        targetImageView.isHidden = true
//        
//        // Deselect the model in the collection view
//        if let selectedIndexPath = modelSelectionCollectionView.indexPathsForSelectedItems?.first {
//            modelSelectionCollectionView.deselectItem(at: selectedIndexPath, animated: true)
//        }
//        selectedModelName = nil
//        
//        // Update instruction
//        instructionLabel.text = "All models removed. Select a model from the bottom menu to place it in your room."
//        
//        // Provide haptic feedback
//        let feedbackGenerator = UINotificationFeedbackGenerator()
//        feedbackGenerator.notificationOccurred(.warning)
//    }
//    
//    @objc private func doneButtonTapped() {
//        // Check if we have any models placed
//        if placedModels.isEmpty {
//            let alert = UIAlertController(
//                title: "No Models Placed",
//                message: "You haven't placed any models in your room. Do you want to exit anyway?",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "Stay Here", style: .cancel))
//            alert.addAction(UIAlertAction(title: "Exit", style: .default) { _ in
//                self.delegate?.modelPlacementCompleted()
//            })
//            present(alert, animated: true)
//        } else {
//            // Notify delegate that model placement is complete
//            delegate?.modelPlacementCompleted()
//        }
//    }
//    
//    @objc private func cancelButtonTapped() {
//        // Notify delegate that model placement was cancelled
//        delegate?.modelPlacementCancelled()
//    }
//    
//    @objc private func rotationSliderChanged(_ sender: UISlider) {
//        if let node = selectedNode ?? placementNode {
//            // Apply rotation around Y axis
//            node.eulerAngles.y = sender.value
//        }
//    }
//    
//    @objc private func scaleSliderChanged(_ sender: UISlider) {
//        if let node = selectedNode ?? placementNode {
//            // Apply scale
//            let scale = sender.value
//            node.scale = SCNVector3(scale, scale, scale)
//        }
//    }
//    
//    @objc private func deleteButtonTapped() {
//        guard let selectedNode = selectedNode else { return }
//        
//        // Remove the node from the scene
//        selectedNode.removeFromParentNode()
//        
//        // Remove from placed models array
//        if let index = placedModels.firstIndex(of: selectedNode) {
//            placedModels.remove(at: index)
//        }
//        
//        // Reset selection
//        self.selectedNode = nil
//        
//        // Hide sliders and control panel
//        rotationSlider.isHidden = true
//        scaleSlider.isHidden = true
//        controlPanel.isHidden = true
//        
//        // Update instruction
//        instructionLabel.text = "Model deleted. Select another model to place or edit."
//        
//        // Provide haptic feedback
//        let feedbackGenerator = UINotificationFeedbackGenerator()
//        feedbackGenerator.notificationOccurred(.success)
//    }
//    
//    @objc private func duplicateButtonTapped() {
//        guard let selectedNode = selectedNode else { return }
//        
//        // Create a duplicate of the selected node
//        let duplicateNode = selectedNode.clone()
//        duplicateNode.name = "placed_model_\(UUID().uuidString)"
//        
//        // Offset the position slightly to make it visible
//        duplicateNode.position = SCNVector3(
//            selectedNode.position.x + 0.1,
//            selectedNode.position.y,
//            selectedNode.position.z + 0.1
//        )
//        
//        // Add to scene and track
//        sceneView.scene.rootNode.addChildNode(duplicateNode)
//        placedModels.append(duplicateNode)
//        
//        // Reset selection
//        self.selectedNode?.childNodes.forEach { node in
//            node.geometry?.materials.forEach { material in
//                material.emission.contents = nil
//            }
//        }
//        self.selectedNode = duplicateNode
//        
//        // Highlight the new node
//        duplicateNode.childNodes.forEach { node in
//            node.geometry?.materials.forEach { material in
//                material.emission.contents = UIColor.green.withAlphaComponent(0.3)
//            }
//        }
//        
//        // Hide control panel but keep sliders visible
//        controlPanel.isHidden = true
//        
//        // Update instruction
//        instructionLabel.text = "Model duplicated. You can now adjust its position, rotation, and scale."
//        
//        // Provide haptic feedback
//        let feedbackGenerator = UINotificationFeedbackGenerator()
//        feedbackGenerator.notificationOccurred(.success)
//    }
//    
//    // MARK: - ARSCNViewDelegate
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        // Update the position of the placement node if it exists
//        if placementNode != nil {
//            updatePlacementPosition()
//        }
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // Handle newly added anchors if needed
//    }
//    
//    // MARK: - UICollectionViewDataSource
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return availableModels.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModelCell", for: indexPath) as! ModelCell
//        cell.configure(with: availableModels[indexPath.item])
//        return cell
//    }
//    
//    // MARK: - UICollectionViewDelegate
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedModelName = availableModels[indexPath.item]
//        loadModel(named: selectedModelName!)
//        
//        // Deselect any previously selected model
//        selectedNode?.childNodes.forEach { node in
//            node.geometry?.materials.forEach { material in
//                material.emission.contents = nil
//            }
//        }
//        selectedNode = nil
//        
//        // Hide control panel
//        controlPanel.isHidden = true
//    }
//    
//    // MARK: - Helper Methods
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
