import SwiftUI
import SceneKit

/// A UIViewRepresentable that wraps SCNView, sets an interior camera,
/// and handles tap-to-color and first-person controls, plus camera reset.
struct TappableSceneView: UIViewRepresentable {
    let scene: SCNScene
    let onNodeTap: (SCNNode) -> Void
    @Binding var coordinator: Coordinator?

    func makeCoordinator() -> Coordinator {
        Coordinator(onNodeTap: onNodeTap)
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene
        scnView.backgroundColor = .black

        // Create and position the interior camera
        let cameraNode = SCNNode()
        cameraNode.name = "cameraNode"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 1.6, z: 0)
        cameraNode.eulerAngles = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode

        // let coordinator hold references
        context.coordinator.scnView = scnView
        context.coordinator.cameraNode = cameraNode
        context.coordinator.storeInitialTransform()

        // Set the coordinator binding back
        DispatchQueue.main.async {
            self.coordinator = context.coordinator
        }

        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false

        // One-finger pan: look around
        let lookPan = UIPanGestureRecognizer(target: context.coordinator,
                                             action: #selector(Coordinator.handlePan(_:)))
        lookPan.minimumNumberOfTouches = 1
        lookPan.maximumNumberOfTouches = 1
        scnView.addGestureRecognizer(lookPan)

        // Two-finger pan: move
        let movePan = UIPanGestureRecognizer(target: context.coordinator,
                                             action: #selector(Coordinator.handleMovePan(_:)))
        movePan.minimumNumberOfTouches = 2
        movePan.maximumNumberOfTouches = 2
        scnView.addGestureRecognizer(movePan)

        // Tap: recolor
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tap)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) { }

    class Coordinator: NSObject {
        let onNodeTap: (SCNNode) -> Void
        weak var scnView: SCNView?
        weak var cameraNode: SCNNode?
        private var initialPosition: SCNVector3 = SCNVector3Zero
        private var initialEuler: SCNVector3 = SCNVector3Zero

        init(onNodeTap: @escaping (SCNNode) -> Void) {
            self.onNodeTap = onNodeTap
            super.init()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMoveNotification(_:)),
                                                   name: .moveCamera,
                                                   object: nil)
        }

        /// Store initial camera transform
        func storeInitialTransform() {
            guard let cam = cameraNode else { return }
            initialPosition = cam.position
            initialEuler = cam.eulerAngles
        }

        /// Reset camera to initial
        func resetCamera() {
            guard let cam = cameraNode else { return }
            cam.position = initialPosition
            cam.eulerAngles = initialEuler
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scn = scnView else { return }
            let hits = scn.hitTest(gesture.location(in: scn), options: nil)
            if let firstHit = hits.first {
                onNodeTap(firstHit.node)
            }
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let scn = scnView,
                  let cam = cameraNode else { return }
            let translation = gesture.translation(in: scn)
            let sensitivity: Float = 0.005
            cam.eulerAngles.y -= Float(translation.x) * sensitivity
            cam.eulerAngles.x -= Float(translation.y) * sensitivity
            gesture.setTranslation(.zero, in: scn)
        }

        @objc func handleMovePan(_ gesture: UIPanGestureRecognizer) {
            guard let scn = scnView,
                  let cam = cameraNode else { return }
            let translation = gesture.translation(in: scn)
            let moveSens: Float = 0.01
            let yaw = cam.eulerAngles.y
            let forward = SCNVector3(-sin(yaw), 0, -cos(yaw))
            let right = SCNVector3(cos(yaw), 0, -sin(yaw))
            cam.position.x += (forward.x * Float(-translation.y) + right.x * Float(translation.x)) * moveSens
            cam.position.z += (forward.z * Float(-translation.y) + right.z * Float(translation.x)) * moveSens
            gesture.setTranslation(.zero, in: scn)
        }

        @objc func handleMoveNotification(_ notification: Notification) {
            guard let direction = notification.userInfo?["direction"] as? CameraMovement,
                  let cam = cameraNode else { return }

            let moveStep: Float = 0.1
            let yaw = cam.eulerAngles.y
            let forward = SCNVector3(-sin(yaw), 0, -cos(yaw))
            let right = SCNVector3(cos(yaw), 0, -sin(yaw))

            switch direction {
            case .forward:
                cam.position.x += forward.x * moveStep
                cam.position.z += forward.z * moveStep
            case .backward:
                cam.position.x -= forward.x * moveStep
                cam.position.z -= forward.z * moveStep
            case .left:
                cam.position.x -= right.x * moveStep
                cam.position.z -= right.z * moveStep
            case .right:
                cam.position.x += right.x * moveStep
                cam.position.z += right.z * moveStep
            }
        }
    }
}

enum CameraMovement {
    case forward, backward, left, right
}

extension Notification.Name {
    static let resetCameraManual = Notification.Name("resetCameraManual")
    static let moveCamera = Notification.Name("moveCamera")
}

/// Full-screen SwiftUI view that hosts the tappable interior scene with Reset button
struct ModelEditorView: View {
    @State private var scene: SCNScene?
    @State private var coordinator: TappableSceneView.Coordinator?
    let modelName: String
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let scene = scene {
                GeometryReader { proxy in
                    TappableSceneView(scene: scene, onNodeTap: { node in
                        if let mat = node.geometry?.firstMaterial {
                            mat.diffuse.contents = UIColor.random()
                        }
                    }, coordinator: $coordinator)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .edgesIgnoringSafeArea(.all)
                }
            } else {
                Text("Loading 3D interior view…")
                    .italic()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
            }

            Button(action: {
                NotificationCenter.default.post(name: .resetCameraManual, object: nil)
            }) {
                Text("Reset Position")
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(8)
                    .padding()
            }

//            VStack {
//                Button("↑") {
//                    NotificationCenter.default.post(name: .moveCamera, object: nil, userInfo: ["direction": CameraMovement.forward])
//                }
//                HStack {
//                    Button("←") {
//                        NotificationCenter.default.post(name: .moveCamera, object: nil, userInfo: ["direction": CameraMovement.left])
//                    }
//                    Spacer().frame(width: 30)
//                    Button("→") {
//                        NotificationCenter.default.post(name: .moveCamera, object: nil, userInfo: ["direction": CameraMovement.right])
//                    }
//                }
//                Button("↓") {
//                    NotificationCenter.default.post(name: .moveCamera, object: nil, userInfo: ["direction": CameraMovement.backward])
//                }
//            }
//            .padding()
//            .background(Color.white.opacity(0.6))
//            .cornerRadius(10)
//            .padding()
//            .position(x: 100, y: 300)
        }
        .onAppear {
            loadScene(named: modelName)
            NotificationCenter.default.addObserver(forName: .resetCameraManual,
                                                   object: nil,
                                                   queue: .main) { _ in
                coordinator?.resetCamera()
            }
        }
    }

    private func loadScene(named name: String) {
        guard let url = RoominatorFileManager.shared.getUSDZFileURL(for: name) else { return }
        do {
            let loaded = try SCNScene(url: url, options: nil)
            loaded.rootNode.enumerateChildNodes { node, _ in
                node.geometry?.firstMaterial?.isDoubleSided = true
            }
            scene = loaded
        } catch {
            print("Failed to load scene: \(error)")
        }
    }
}

// Random color helper
private extension UIColor {
    static func random() -> UIColor {
        UIColor(red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1)
    }
}

//struct ModelEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelEditorView()
//    }
//}
