//
//  PlayerNode.swift
//  Slider Chopper
//
//  Created by Drew Bayles on 5/3/23.
//

import Foundation
import SpriteKit
import CoreMotion

class PlayerNode: SKSpriteNode, SKPhysicsContactDelegate {
    
    let motionManager = CMMotionManager()
    
    init() {
        super.init(texture: nil, color: .white, size: CGSize(width: 50, height: 50))
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.startAccelerometerUpdates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAccelerometerUpdates() {
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let acceleration = data?.acceleration else { return }
            let xAcceleration = CGFloat(acceleration.x) * 20 // Adjust this value to control sensitivity
            self?.physicsBody?.applyForce(CGVector(dx: xAcceleration, dy: 0))
        }
    }
    
}
