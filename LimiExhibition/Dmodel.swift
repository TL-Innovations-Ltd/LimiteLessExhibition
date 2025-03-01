//
//  ContentView.swift
//  Scene
//
//  Created by Balaji on 01/08/20.
//

import SwiftUI
import SceneKit

//
//struct CustomerSceneView: View {
//    @Binding
//}
//

struct Dmodel: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Dmodel()
    }
}

struct CustomerSceneView: UIViewRepresentable {
    var modelName: String
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        if let scene = SCNScene(named: modelName) {
            scene.background.contents = UIColor.clear
            sceneView.scene = scene
            
            // Optional: Adjust camera position
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            scene.rootNode.addChildNode(cameraNode)
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = SCNScene(named: modelName) {
            scene.background.contents = UIColor.clear
            uiView.scene = scene
        }
    }
}
// Home View...

struct Home : View {
    
    @State var models = [
        
        Model(id: 0, name: "Stand Lamp", modelName: "modela.usdz", details: "Earth is the third planet from the Sun and the only astronomical object known to harbor life. According to radiometric dating estimation and other evidence, Earth formed over 4.5 billion years ago. Earth's gravity interacts with other objects in space, especially the Sun and the Moon, which is Earth's only natural satellite. Earth orbits around the Sun in 365.256 solar days."),
        
        Model(id: 0, name: "Bulbs", modelName: "Bulbs.usdz", details: "Jupiter is the largest planet in our solar system at nearly 11 times the size of Earth and 317 times its mass. Jupiter, being the biggest planet, gets its name from the king of the ancient Roman gods."),]

    @State var index = 0
    
    var body: some View{
        
        VStack{
            
            // Going to use SceneKit Scene View....
            
            // default is first object ie: Earth...
            
            // Scene View Has a default Camera View...
            // if you nedd custom means add there...
            
            CustomerSceneView(modelName: models[index].modelName)
            .frame(height: UIScreen.main.bounds.height / 2)

            
// Ensure SwiftUI background is also transparent

            
            
            ZStack{
                
                // Forward and backward buttons...
                
                HStack{
                    
                    Button(action: {
                        
                        withAnimation{
                            
                            if index > 0{
                                
                                index -= 1
                            }
                        }
                        
                    }, label: {
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 35, weight: .bold))
                            .opacity(index == 0 ? 0.3 : 1)
                    })
                    .disabled(index == 0 ? true : false)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {
                        
                        withAnimation{
                            
                            if index < models.count{
                                
                                index += 1
                            }
                        }
                        
                    }, label: {
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 35, weight: .bold))
                        // disabling button when no other data ....
                            .opacity(index == models.count - 1 ? 0.3 : 1)
                    })
                    .disabled(index == models.count - 1 ? true : false)
                }
                
                Text(models[index].name)
                    .font(.system(size: 45, weight: .bold))
            }
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.vertical,30)
            
            // Details....
            
            VStack(alignment: .leading, spacing: 15, content: {
                
                Text("About")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(models[index].details)
            })
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
        .background(Color.alabaster)
    }
}

// Data Model...

struct Model : Identifiable {
    
    var id : Int
    var name : String
    var modelName : String
    var details : String
}

// Sample Data...

// To Load obj Files.....
