import SwiftUI
import RealityKit
import ARKit

struct ARContentView: View {
    @State private var selectedModelName: String = "CeilingPendant"
    let modelNames = ["CeilingPendant", "MultiplePendants", "FloorLamp", "WallLight"]

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(selectedModelName: $selectedModelName)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(modelNames, id: \.self) { model in
                        Button(action: {
                            selectedModelName = model
                        }) {
                            Text(model)
                                .padding()
                                .background(selectedModelName == model ? Color.blue : Color.white)
                                .foregroundColor(selectedModelName == model ? .white : .black)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedModelName: String

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // ARSession configuration for plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)

        context.coordinator.arView = arView
        context.coordinator.selectedModelName = selectedModelName

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.selectedModelName = selectedModelName
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var arView: ARView?
        var selectedModelName: String = ""

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            let location = sender.location(in: arView)
            if let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                let anchor = AnchorEntity(world: raycastResult.worldTransform)

                // Load the selected model (Make sure the model name corresponds to the filename)
                let modelNameWithPath = selectedModelName + ".usdz"
                if let modelEntity = try? ModelEntity.loadModel(named: modelNameWithPath) {
                    modelEntity.generateCollisionShapes(recursive: true) // Add collision shapes for interaction
                    anchor.addChild(modelEntity)
                    arView.scene.anchors.append(anchor)
                } else {
                    print("Failed to load \(modelNameWithPath) model. Ensure the model is included in the project and the filename is correct.")
                }
            }
        }
    }
}
