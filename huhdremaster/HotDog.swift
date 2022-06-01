//
//  HotDog.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/31/22.
//

import SpriteKit

class HotDog: BaseSprite {
    let standardTexture: SKTexture = SKTexture(imageNamed: "dog54x12.png")
    let fallingTexture: SKTexture = SKTexture(imageNamed: "Dog_Fall.png")
    let risingTexture: SKTexture = SKTexture(imageNamed: "Dog_Rise.png")
    var isGrabbed: Bool = false
    var previousDragPosition: CGPoint = CGPoint(x:0, y:0)
    
    init(scene: BaseScene) {
        super.init(texture: standardTexture)
        self.setRandomPosition()
        self.physicsBody = SKPhysicsBody(texture: self.texture!,
                                           size: CGSize(width: self.size.width,
                                                        height: self.size.height))
        self.physicsBody?.restitution = 0.9
        self.physicsBody?.collisionBitMask = UInt32.random(in:0...3) | 0b1000
        self.zPosition = 30
        self.setScene(scene: scene)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func update() {
        if ((self.physicsBody?.velocity.dy)! < 2 && self.texture != fallingTexture) {
            self.texture = fallingTexture
        } else if ((self.physicsBody?.velocity.dy)! > 2 && self.texture != risingTexture) {
            self.texture = risingTexture
        } else if (self.texture != standardTexture) {
            self.texture = standardTexture
        }
    }
    
    func grab() {
        self.isGrabbed = true
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
