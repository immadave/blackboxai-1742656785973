import SceneKit

class GameScene: SCNScene, SCNSceneRendererDelegate {
    
    // Scene components
    private var camera: SCNNode!
    private var playerNode: SCNNode!
    private var levelManager: LevelManager!
    
    // Game state
    private var lastUpdateTime: TimeInterval = 0
    private var gameSpeed: Float = 0.0
    private let maxGameSpeed: Float = 100.0
    
    override init() {
        super.init()
        Logger.shared.log("Initializing GameScene")
        
        setupScene()
        setupCamera()
        setupLighting()
        setupPlayer()
        setupEnvironment()
        
        levelManager = LevelManager(scene: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScene() {
        // Set up physics world
        physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        physicsWorld.speed = 1.0
        
        // Set up background
        background.contents = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        
        Logger.shared.log("Scene basic setup completed")
    }
    
    private func setupCamera() {
        camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.zFar = 500 // Render distance
        camera.position = SCNVector3(0, 10, 20) // Initial position behind and above the player
        camera.eulerAngles = SCNVector3(-0.3, 0, 0) // Look slightly downward
        
        rootNode.addChildNode(camera)
        Logger.shared.log("Camera setup completed")
    }
    
    private func setupLighting() {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 500
        ambientLight.light?.color = UIColor(white: 0.5, alpha: 1.0)
        rootNode.addChildNode(ambientLight)
        
        // Directional light (sun)
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = .directional
        sunLight.light?.intensity = 1000
        sunLight.light?.color = UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
        sunLight.position = SCNVector3(50, 100, 50)
        sunLight.eulerAngles = SCNVector3(-0.5, 0.5, 0)
        rootNode.addChildNode(sunLight)
        
        Logger.shared.log("Lighting setup completed")
    }
    
    private func setupPlayer() {
        // Create a temporary hovercraft geometry (will be replaced with proper model)
        let hovercraftGeometry = SCNBox(width: 2.0, height: 0.5, length: 4.0, chamferRadius: 0.2)
        hovercraftGeometry.firstMaterial?.diffuse.contents = UIColor.cyan
        hovercraftGeometry.firstMaterial?.specular.contents = UIColor.white
        
        playerNode = SCNNode(geometry: hovercraftGeometry)
        playerNode.position = SCNVector3(0, 5, 0)
        
        // Add physics body
        let shape = SCNPhysicsShape(geometry: hovercraftGeometry, options: nil)
        playerNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        playerNode.physicsBody?.mass = 1.0
        playerNode.physicsBody?.friction = 0.5
        playerNode.physicsBody?.restitution = 0.3
        
        rootNode.addChildNode(playerNode)
        Logger.shared.log("Player setup completed")
    }
    
    private func setupEnvironment() {
        // Create a temporary ground plane
        let groundGeometry = SCNFloor()
        groundGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
        groundGeometry.firstMaterial?.specular.contents = UIColor.white
        
        let groundNode = SCNNode(geometry: groundGeometry)
        groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        groundNode.physicsBody?.friction = 0.5
        groundNode.physicsBody?.restitution = 0.0
        
        rootNode.addChildNode(groundNode)
        Logger.shared.log("Environment setup completed")
    }
    
    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : time - lastUpdateTime
        lastUpdateTime = time
        
        // Update game components
        updateCamera(deltaTime)
        levelManager.update(deltaTime)
        
        // Increase game speed over time
        gameSpeed = min(gameSpeed + Float(deltaTime) * 2, maxGameSpeed)
    }
    
    private func updateCamera(deltaTime: TimeInterval) {
        guard let playerPosition = playerNode?.position else { return }
        
        // Camera follows player with smooth interpolation
        let targetPosition = SCNVector3(
            playerPosition.x,
            playerPosition.y + 10,
            playerPosition.z + 20
        )
        
        let smoothFactor: Float = 0.1
        camera.position = SCNVector3(
            camera.position.x + (targetPosition.x - camera.position.x) * smoothFactor,
            camera.position.y + (targetPosition.y - camera.position.y) * smoothFactor,
            camera.position.z + (targetPosition.z - camera.position.z) * smoothFactor
        )
        
        // Keep camera looking at player
        let lookAtConstraint = SCNLookAtConstraint(target: playerNode)
        lookAtConstraint.isGimbalLockEnabled = true
        camera.constraints = [lookAtConstraint]
    }
    
    // MARK: - Game State Management
    
    func resetGame() {
        gameSpeed = 0
        playerNode.position = SCNVector3(0, 5, 0)
        playerNode.physicsBody?.velocity = SCNVector3Zero
        playerNode.physicsBody?.angularVelocity = SCNVector4Zero
        levelManager.reset()
        Logger.shared.log("Game reset completed")
    }
    
    // MARK: - Player Control Methods
    
    func movePlayer(direction: SCNVector3) {
        playerNode.physicsBody?.applyForce(direction, asImpulse: true)
    }
    
    func boostPlayer() {
        let boostForce = SCNVector3(0, 0, -50)
        playerNode.physicsBody?.applyForce(boostForce, asImpulse: true)
        Logger.shared.log("Player boost activated")
    }
    
    func driftPlayer(amount: Float) {
        let driftForce = SCNVector3(amount * 10, 0, 0)
        playerNode.physicsBody?.applyForce(driftForce, asImpulse: true)
        Logger.shared.log("Player drift: \(amount)")
    }
}