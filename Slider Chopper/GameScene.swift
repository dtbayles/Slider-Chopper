//
//  GameScene.swift
//  Slider Chopper
//
//  Created by Drew Bayles on 3/26/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player: PlayerNode!
    
    private var scoreLabel: SKLabelNode!
    private var score = 0
    
    let playerCategory: UInt32 = 0x1 << 0
    let sliderCategory: UInt32 = 0x1 << 1
    
    private var gameStarted = false
    private var isGamePaused = false
    private var pauseButton: SKSpriteNode!
    
    private var lastSliderGenerationTime: TimeInterval?
    
    override func didMove(to view: SKView) {
        // Set up physics world
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -2.8)
        
        // Set up player
        player = PlayerNode()
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = sliderCategory
        player.position = CGPoint(x: frame.midX, y: frame.minY + player.size.height)
        addChild(player)
        
        // Set up pause button
        pauseButton = SKSpriteNode(imageNamed: "pause_button")
        pauseButton.setScale(0.2)
        pauseButton.position = CGPoint(x: frame.minX + 125, y: frame.maxY - pauseButton.size.height)
        addChild(pauseButton)
        
        // Set up score label
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: frame.minX + scoreLabel.frame.size.width, y: frame.maxY - pauseButton.size.height - scoreLabel.frame.size.height * 2 - 10)
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        
        // Set up lastSliderGenerationTime
        lastSliderGenerationTime = 0
    }

    func createSlider() {
        // Create a slider and add it to the scene
        let slider = SliderNode()
        slider.physicsBody?.categoryBitMask = sliderCategory
        slider.physicsBody?.contactTestBitMask = playerCategory
        slider.position = CGPoint(x: CGFloat.random(in: -(frame.width - slider.size.width * 4) / 2 ..< (frame.width - slider.size.width * 4) / 2), y: frame.maxY)
        addChild(slider)

        // Set up slider movement
//        let moveSlider = SKAction.moveBy(x: 0, y: -((frame.maxY * 2) + slider.size.height), duration: 3)
//        let removeSlider = SKAction.removeFromParent()
//        slider.run(SKAction.sequence([moveSlider, removeSlider]))
    }
    
    func eatSlider(slider: SKSpriteNode) {
        // Remove slider from scene and update score
        slider.removeFromParent()
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            // Set up slider generation timer
//            let generateSliders = SKAction.repeatForever(SKAction.sequence([
//                SKAction.run(createSlider),
//                SKAction.wait(forDuration: 1)
//            ]))
//            run(generateSliders)
            gameStarted = true
        } else {
            for touch in touches {
                let location = touch.location(in: self)
                let nodesAtPoint = nodes(at: location)
                if nodesAtPoint.contains(pauseButton) {
                    if isGamePaused {
                        // Resume the game
                        isGamePaused = false
                        // Hide pause menu or resume game logic here
                    } else {
                        // Pause the game
                        isGamePaused = true
                        // Show pause menu or pause game logic here
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if isGamePaused {
            return // Skip game logic when game is paused
        }
        
        // Move the player horizontally based on device tilt
        if let acceleration = player.motionManager.accelerometerData?.acceleration {
            let newX = player.position.x + CGFloat(acceleration.x * 50)
            let minX = frame.minX + player.size.width * 2
            let maxX = frame.maxX - player.size.width * 2
            player.position.x = max(min(newX, maxX), minX)
            player.position.y = frame.minY + player.size.height
        }
        
        // Generate sliders
        let sliderGenerationInterval: TimeInterval = 1
        let timeSinceLastSliderGeneration = currentTime - (lastSliderGenerationTime ?? 0)
        if timeSinceLastSliderGeneration > sliderGenerationInterval {
            createSlider()
            lastSliderGenerationTime = currentTime
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == sliderCategory {
            // Contact occurred between player and slider
            score += 1
            scoreLabel.text = "Score: \(score)"
            contact.bodyB.node?.removeFromParent() // Remove the slider from the scene
        } else if contact.bodyA.categoryBitMask == sliderCategory && contact.bodyB.categoryBitMask == playerCategory {
            // Contact occurred between slider and player
            score += 1
            scoreLabel.text = "Score: \(score)"
            contact.bodyA.node?.removeFromParent() // Remove the slider from the scene
        }
    }
    
    override func didSimulatePhysics() {
        // Check if any sliders have fallen off the screen
        for slider in children.filter({ $0.physicsBody?.categoryBitMask == sliderCategory }) {
            if slider.position.y < frame.minY {
                slider.removeFromParent()
                score -= 1
                scoreLabel.text = "Score: \(score)"
            }
        }
    }

}
