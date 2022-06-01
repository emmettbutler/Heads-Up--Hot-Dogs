//
//  HotDog.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/31/22.
//

import SpriteKit

class HotDog: BaseSprite {
    static let categoryBitMask: UInt32 = 0b10000000
    let standardTexture: SKTexture = SKTexture(imageNamed: "dog54x12.png")
    let fallingTexture: SKTexture = SKTexture(imageNamed: "Dog_Fall.png")
    let risingTexture: SKTexture = SKTexture(imageNamed: "Dog_Rise.png")
    var isGrabbed: Bool = false
    var previousDragPosition: CGPoint = CGPoint(x:0, y:0)
    var lastFloorContactTime: TimeInterval = -1
    var lastGrabTime: TimeInterval = -1
    
    init(scene: BaseScene) {
        super.init(texture: standardTexture)
        self.setRandomPosition()
        self.physicsBody = SKPhysicsBody(texture: self.texture!,
                                           size: CGSize(width: self.size.width,
                                                        height: self.size.height))
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.collisionBitMask = UInt32.random(in:0...3) | 0b1000
        self.physicsBody?.categoryBitMask = HotDog.categoryBitMask
        self.zPosition = 30
        self.setScene(scene: scene)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func update(currentTime: TimeInterval) {
        self.updateTexture()
        self.resolveDespawnConditions(currentTime: currentTime)
    }
    
    func resolveDespawnConditions(currentTime: TimeInterval) {
        let timeSinceFloorContact: TimeInterval = currentTime - self.lastFloorContactTime
        let timeSinceGrab: TimeInterval = currentTime - self.lastGrabTime
        if self.lastFloorContactTime != -1 && !self.isGrabbed && timeSinceFloorContact > 3 && timeSinceGrab > 3 {
            self.shouldBeDespawned = true
        }
    }
    
    func updateTexture() {
        if ((self.physicsBody?.velocity.dy)! < -10 && self.texture != fallingTexture) {
            self.texture = fallingTexture
        } else if ((self.physicsBody?.velocity.dy)! > 10 && self.texture != risingTexture) {
            self.texture = risingTexture
        } else if (self.texture != standardTexture) {
            self.texture = standardTexture
        }
    }
    
    func contactedFloor(currentTime: TimeInterval) {
        self.lastFloorContactTime = currentTime
    }
    
    func grab(currentTime: TimeInterval) {
        self.isGrabbed = true
        self.lastGrabTime = currentTime
        self.lastFloorContactTime = -1
        self.physicsBody?.isDynamic = false
    }
    
    func releaseGrab() {
        self.isGrabbed = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.applyImpulse(CGVector(dx:self.position.x - self.previousDragPosition.x,
                                                dy: self.position.y - self.previousDragPosition.y))
    }
    
    func drag(toPos: CGPoint) {
        if self.isGrabbed {
            self.previousDragPosition = self.position
            self.position = toPos
        }
    }
}