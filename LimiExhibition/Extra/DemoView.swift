//
//  DemoView.swift
//  LimitLess
//
//  Created by Mac Mini on 21/02/2025.
//


import SwiftUI
import SwiftUI
import UIKit

// UIKit ViewController to handle rotation
class RotatableViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var shouldAutorotate: Bool {
        return true
    }
}

struct DemoView: View {
    @State private var isSidebarOpen = false

    var body: some View {
        ZStack {
            // Main Content
            NavigationView {
                VStack {
                    Button(action: {
                        withAnimation {
                            isSidebarOpen.toggle()
                        }
                    }) {
                        Text("Open Menu")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Button to trigger rotation
                    Button(action: {
                        // Toggle between portrait and landscape
                        let currentOrientation = UIDevice.current.orientation
                        let newOrientation: UIInterfaceOrientation = currentOrientation == .portrait ? .landscapeRight : .portrait
                        UIDevice.current.setValue(newOrientation.rawValue, forKey: "orientation")
                    }) {
                        Text("Rotate Screen")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

            }

            // Sidebar Menu
            if isSidebarOpen {
                ZStack {
                    // Background Overlay
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isSidebarOpen.toggle()
                            }
                        }
                    
                    // Sidebar Content
                    HStack {
                        VStack(alignment: .leading) {
                            Button(action: {
                                withAnimation {
                                    isSidebarOpen.toggle()
                                }
                            }) {
                                Text("Close")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                            .padding(.top, 40)

                            Spacer()
                            
                            Text("Menu 1")
                                .padding()
                            Text("Menu 2")
                                .padding()
                            Text("Menu 3")
                                .padding()

                            Spacer()
                        }
                        .frame(width: 250)
                        .background(Color.gray)
                        .edgesIgnoringSafeArea(.vertical)

                        Spacer()
                    }
                }
            }
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
