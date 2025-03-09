//
//  GIFView.swift
//  Limi
//
//  Created by Mac Mini on 09/03/2025.
//


import SwiftUI
import FLAnimatedImage

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> FLAnimatedImageView {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ uiView: FLAnimatedImageView, context: Context) {
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let gifImage = FLAnimatedImage(animatedGIFData: data)
            uiView.animatedImage = gifImage
        }
    }
}