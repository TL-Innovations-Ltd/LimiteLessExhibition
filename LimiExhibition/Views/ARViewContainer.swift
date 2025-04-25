import SwiftUI
import ARKit
import SceneKit

struct ContentViewAR: View {
    @State private var selectedModel = "FloorLamp"
    
    let modelNames = [
        "FloorLamp",
        "MultiplePendants",
        "TexturedLight",
        "WallLight"
    ]
    
    var body: some View {
        VStack {
            Picker("Model", selection: $selectedModel) {
                ForEach(modelNames, id: \.self) { model in
                Text(model)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ARViewContainer(selectedModelName: $selectedModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedModelName: String
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var modelNode: SCNNode?
        var sceneView: ARSCNView?
        
        // Handle plane detection and add blue rectangle to the surface
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                
                // Set the blue color with transparency for the detected surface
                let planeNode = SCNNode(geometry: plane)
                planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                planeNode.eulerAngles.x = -.pi / 2
                planeNode.opacity = 0.5  // Make it semi-transparent
                plane.materials.first?.diffuse.contents = UIColor.blue
                
                // Add the planeNode to the parent node (the detected surface)
                node.addChildNode(planeNode)
            }
        }
        
        // Handle tap gestures for object placement
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? ARSCNView else { return }
            let location = gesture.location(in: view)
            let results = view.hitTest(location, types: .existingPlaneUsingExtent)
            if let result = results.first {
                placeModel(at: result.worldTransform, in: view)
            }
        }
        
        // Place model on detected plane
        func placeModel(at transform: simd_float4x4, in sceneView: ARSCNView) {
            modelNode?.removeFromParentNode()
            guard let scene = SCNScene(named: "art.scnassets/\(selectedModelName).usdz") else { return }
            let node = scene.rootNode.clone()
            node.position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(node)
            modelNode = node
        }
        
        var selectedModelName: String = "FloorLamp"
        
        func updateModelName(_ name: String) {
            selectedModelName = name
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        context.coordinator.sceneView = sceneView
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.updateModelName(selectedModelName)
    }
}
