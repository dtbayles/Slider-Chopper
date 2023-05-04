//
//  SliderNode.swift
//  Slider Chopper
//
//  Created by Drew Bayles on 5/3/23.
//

import Foundation
import SpriteKit
import CoreMotion

class SliderNode: SKSpriteNode, SKPhysicsContactDelegate {
    init() {
        super.init(texture: nil, color: .blue, size: CGSize(width: 50, height: 50))
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
