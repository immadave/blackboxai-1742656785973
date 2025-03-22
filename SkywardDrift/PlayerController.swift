import SceneKit
import UIKit

class PlayerController {
    private weak var scene: GameScene?
    
    // Movement parameters
    private let maxSpeed: Float = 100.0
    private let acceleration: Float = 20.0
    private let turnSpeed: Float = 2.0
    private let driftFactor: Float = 1.5
    private let boostMultiplier: Float = 2.0
    
    // Player state
    private var currentSpeed: Float = 0.0
    private var isBoosting: Bool = false
    private var isDrifting: Bool = false
    private var lastDriftDirection: Float = 0.0
    private var boostCooldown: TimeInterval = 0.0
    private let boostCooldownDuration: TimeInterval = 3.0
    
    // Energy management
    private var energy: Float = 100.0
    private let maxEnergy: Float = 100.0
    private let energyRegenRate: Float = 10.0
    private let boostEnergyCost: Float = 30.0
    private let driftEnergyCost: Float = 5.0
    
    init(scene: GameScene) {
        self.scene = scene
        Logger.shared.log("PlayerController initialized")
    }
    
    // MARK: - Input Handling
    
    func handlePan(translation: CGPoint, state: UIGestureRecognizer.State) {
        guard let scene = scene else { return }
        
        // Calculate drift amount based on horizontal pan
        let driftAmount = Float(translation.x) / 100.0
        
        switch state {
        case .began:
            isDrifting = true
            lastDriftDirection = driftAmount
            Logger.shared.log("Drift began: \(driftAmount)")
            
        case .changed:
            if isDrifting && energy >= driftEnergyCost {
                scene.driftPlayer(amount: driftAmount * driftFactor)
                energy -= driftEnergyCost * abs(driftAmount) * Float(1.0/60.0) // Energy cost per frame
                lastDriftDirection = driftAmount
            }
            
        case .ended, .cancelled:
            isDrifting = false
            Logger.shared.log("Drift ended")
            
        default:
            break
        }
    }
    
    func activateBoost() {
        guard let scene = scene,
              !isBoosting,
              boostCooldown <= 0,
              energy >= boostEnergyCost else {
            Logger.shared.log("Boost failed - Cooldown: \(boostCooldown), Energy: \(energy)")
            return
        }
        
        // Activate boost
        isBoosting = true
        energy -= boostEnergyCost
        boostCooldown = boostCooldownDuration
        
        // Apply boost force
        scene.boostPlayer()
        
        // Schedule boost end
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isBoosting = false
            Logger.shared.log("Boost ended")
        }
        
        Logger.shared.log("Boost activated - Energy remaining: \(energy)")
    }
    
    // MARK: - Update Loop
    
    func update(deltaTime: TimeInterval) {
        // Update boost cooldown
        if boostCooldown > 0 {
            boostCooldown -= deltaTime
        }
        
        // Regenerate energy
        if energy < maxEnergy {
            energy = min(energy + Float(deltaTime) * energyRegenRate, maxEnergy)
        }
        
        // Update movement
        updateMovement(deltaTime: deltaTime)
    }
    
    private func updateMovement(deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Calculate base movement
        var moveDirection = SCNVector3(0, 0, -1) // Forward direction
        
        // Apply current speed
        let speedMultiplier = isBoosting ? boostMultiplier : 1.0
        let targetSpeed = maxSpeed * Float(speedMultiplier)
        currentSpeed = min(currentSpeed + acceleration * Float(deltaTime), targetSpeed)
        
        // Apply movement force
        let movementForce = moveDirection * currentSpeed
        scene.movePlayer(direction: movementForce)
        
        // Apply drift if active
        if isDrifting {
            let driftForce = SCNVector3(lastDriftDirection * driftFactor * currentSpeed, 0, 0)
            scene.movePlayer(direction: driftForce)
        }
    }
    
    // MARK: - Helper Methods
    
    private func resetState() {
        currentSpeed = 0.0
        isBoosting = false
        isDrifting = false
        lastDriftDirection = 0.0
        boostCooldown = 0.0
        energy = maxEnergy
        Logger.shared.log("PlayerController state reset")
    }
}

// MARK: - Vector Operations
extension SCNVector3 {
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
}