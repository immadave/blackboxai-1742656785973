import UIKit
import SceneKit
import SwiftUI

class GameViewController: UIViewController {
    private var sceneView: SCNView!
    private var gameScene: GameScene!
    private var playerController: PlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.log("GameViewController loaded")
        
        setupSceneView()
        setupGame()
        setupGestures()
    }
    
    private func setupSceneView() {
        // Create and configure SCNView
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false // We'll control the camera programmatically
        sceneView.showsStatistics = true // Useful for debugging
        sceneView.antialiasingMode = .multisampling4X
        view.addSubview(sceneView)
        
        // Configure rendering options
        sceneView.rendersContinuously = true
        sceneView.preferredFramesPerSecond = 60
        
        Logger.shared.log("SceneView setup completed")
    }
    
    private func setupGame() {
        // Create and configure the game scene
        gameScene = GameScene()
        sceneView.scene = gameScene
        sceneView.delegate = gameScene
        
        // Initialize player controller
        playerController = PlayerController(scene: gameScene)
        
        Logger.shared.log("Game setup completed")
    }
    
    private func setupGestures() {
        // Add pan gesture for controlling the hovercraft
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        // Add tap gesture for boost
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        Logger.shared.log("Gesture recognizers setup completed")
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: sceneView)
        playerController.handlePan(translation: translation, state: gesture.state)
        gesture.setTranslation(.zero, in: sceneView)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            playerController.activateBoost()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

// SwiftUI wrapper for GameViewController
struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Update GameView to use GameViewController
struct GameView: View {
    var body: some View {
        GameViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                Logger.shared.log("GameView appeared with GameViewController")
            }
    }
}