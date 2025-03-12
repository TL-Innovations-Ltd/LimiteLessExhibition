import UIKit
import AVKit
import SwiftUI

class AnimationVideoView: UIViewController {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundVideo()
    }
    
    func playBackgroundVideo() {
        guard let path = Bundle.main.path(forResource: "", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        // Set video to cover the whole screen
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        // Add video layer to the view
        view.layer.insertSublayer(playerLayer!, at: 0)
        
        // Listen for when the video finishes playing
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        player?.play()
    }
    
    @objc func videoDidFinishPlaying() {
        navigatetonBlueextScreen()
    }
    
    func navigatetonBlueextScreen() {
        let nextVC = UIHostingController(rootView: OnboardingView()) // Use SwiftUI View
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
}


import SwiftUI  // ✅ Import SwiftUI

struct AnimationVideoViewPreview: UIViewControllerRepresentable {  // ✅ Corrected struct name
    func makeUIViewController(context: Context) -> AnimationVideoView {
        return AnimationVideoView()
    }

    func updateUIViewController(_ uiViewController: AnimationVideoView, context: Context) {}

}

struct AnimationVideoView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationVideoViewPreview()  // ✅ Use the correct struct name
            .edgesIgnoringSafeArea(.all) // Ensures full-screen preview
    }
}
