import SceneKit

class LevelManager {
    private weak var scene: GameScene?
    private var trackSegments: [SCNNode] = []
    private var obstacles: [SCNNode] = []
    
    // Track generation parameters
    private let segmentLength: Float = 50.0
    private let trackWidth: Float = 20.0
    private let maxSegments: Int = 10
    private let minObstaclesPerSegment: Int = 2
    private let maxObstaclesPerSegment: Int = 5
    
    // Visual effects
    private let neonColors: [UIColor] = [
        UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),  // Cyan
        UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),  // Magenta
        UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),  // Neon Green
        UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)   // Neon Orange
    ]
    
    init(scene: GameScene) {
        self.scene = scene
        setupInitialTrack()
        Logger.shared.log("LevelManager initialized")
    }
    
    // MARK: - Track Generation
    
    private func setupInitialTrack() {
        // Generate initial track segments
        for i in 0..<maxSegments {
            generateTrackSegment(at: Float(i) * segmentLength)
        }
        Logger.shared.log("Initial track setup completed")
    }
    
    private func generateTrackSegment(at zPosition: Float) {
        guard let scene = scene else { return }
        
        // Create track base
        let trackGeometry = SCNBox(
            width: CGFloat(trackWidth),
            height: 0.5,
            length: CGFloat(segmentLength),
            chamferRadius: 0.0
        )
        
        // Create neon material for track
        let trackMaterial = SCNMaterial()
        trackMaterial.diffuse.contents = UIColor.darkGray
        trackMaterial.emission.contents = neonColors.randomElement()
        trackMaterial.emission.intensity = 0.5
        trackGeometry.materials = [trackMaterial]
        
        let trackNode = SCNNode(geometry: trackGeometry)
        trackNode.position = SCNVector3(0, 0, -zPosition)
        trackNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        // Add track barriers
        addTrackBarriers(to: trackNode)
        
        // Add random obstacles
        addObstacles(to: trackNode)
        
        // Add to scene and track segments array
        scene.rootNode.addChildNode(trackNode)
        trackSegments.append(trackNode)
        
        Logger.shared.log("Track segment generated at z: \(-zPosition)")
    }
    
    private func addTrackBarriers(to trackNode: SCNNode) {
        let barrierHeight: Float = 2.0
        let barrierWidth: Float = 0.5
        
        // Create barrier geometry
        let barrierGeometry = SCNBox(
            width: CGFloat(barrierWidth),
            height: CGFloat(barrierHeight),
            length: CGFloat(segmentLength),
            chamferRadius: 0.1
        )
        
        // Create neon material for barriers
        let barrierMaterial = SCNMaterial()
        barrierMaterial.diffuse.contents = UIColor.black
        barrierMaterial.emission.contents = neonColors.randomElement()
        barrierMaterial.emission.intensity = 1.0
        barrierGeometry.materials = [barrierMaterial]
        
        // Left barrier
        let leftBarrier = SCNNode(geometry: barrierGeometry)
        leftBarrier.position = SCNVector3(-trackWidth/2 - barrierWidth/2, barrierHeight/2, 0)
        leftBarrier.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        trackNode.addChildNode(leftBarrier)
        
        // Right barrier
        let rightBarrier = SCNNode(geometry: barrierGeometry)
        rightBarrier.position = SCNVector3(trackWidth/2 + barrierWidth/2, barrierHeight/2, 0)
        rightBarrier.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        trackNode.addChildNode(rightBarrier)
    }
    
    private func addObstacles(to trackNode: SCNNode) {
        let obstacleCount = Int.random(in: minObstaclesPerSegment...maxObstaclesPerSegment)
        
        for _ in 0..<obstacleCount {
            // Random position within track bounds
            let xPos = Float.random(in: -trackWidth/2 + 2...trackWidth/2 - 2)
            let zPos = Float.random(in: -segmentLength/2 + 2...segmentLength/2 - 2)
            
            // Create obstacle
            let obstacle = createRandomObstacle()
            obstacle.position = SCNVector3(xPos, 1.0, zPos)
            
            // Add to track segment
            trackNode.addChildNode(obstacle)
            obstacles.append(obstacle)
        }
    }
    
    private func createRandomObstacle() -> SCNNode {
        let types: [SCNGeometry] = [
            SCNBox(width: 2.0, height: 3.0, length: 2.0, chamferRadius: 0.2),
            SCNCylinder(radius: 1.0, height: 3.0),
            SCNPyramid(width: 2.0, height: 3.0, length: 2.0)
        ]
        
        let geometry = types.randomElement()!
        
        // Create neon material for obstacle
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
        material.emission.contents = neonColors.randomElement()
        material.emission.intensity = 0.8
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        // Add particle effect
        let particleSystem = SCNParticleSystem()
        particleSystem.particleSize = 0.1
        particleSystem.particleColor = material.emission.contents as! UIColor
        particleSystem.emitterShape = geometry
        particleSystem.birthRate = 50
        particleSystem.particleLifeSpan = 1.0
        node.addParticleSystem(particleSystem)
        
        return node
    }
    
    // MARK: - Track Management
    
    func update(_ deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Remove track segments that are too far behind
        while let firstSegment = trackSegments.first,
              firstSegment.position.z > 100 {
            firstSegment.removeFromParentNode()
            trackSegments.removeFirst()
            
            // Generate new segment at the end
            let lastZ = trackSegments.last?.position.z ?? 0
            generateTrackSegment(at: lastZ - segmentLength)
        }
        
        // Update obstacle effects
        updateObstacleEffects(deltaTime)
    }
    
    private func updateObstacleEffects(_ deltaTime: TimeInterval) {
        for obstacle in obstacles {
            // Rotate obstacles slowly
            obstacle.rotation = SCNVector4(
                0,
                1,
                0,
                obstacle.rotation.w + Float(deltaTime)
            )
            
            // Pulse emission intensity
            if let material = obstacle.geometry?.firstMaterial {
                let pulseFrequency: Float = 2.0
                let pulseAmount = (sin(Float(CACurrentMediaTime()) * pulseFrequency) + 1) / 2
                material.emission.intensity = 0.5 + pulseAmount * 0.5
            }
        }
    }
    
    func reset() {
        // Remove all existing track segments and obstacles
        for segment in trackSegments {
            segment.removeFromParentNode()
        }
        trackSegments.removeAll()
        obstacles.removeAll()
        
        // Regenerate initial track
        setupInitialTrack()
        Logger.shared.log("Level reset completed")
    }
}