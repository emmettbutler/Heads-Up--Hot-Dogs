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
    let grabbingTexture: SKTexture = SKTexture(imageNamed: "Dog_Grabbed.png")
    var isGrabbed: Bool = false
    var previousDragPosition: CGPoint = CGPoint(x:0, y:0)
    var previousFloorContactTimes: [TimeInterval] = [TimeInterval]()
    var lastGrabTime: TimeInterval = -1
    let countdownIndicator: ShadowedText = ShadowedText()
    var timeSinceFloorContact: TimeInterval = -1
    var helpIndicator: BaseSprite? = nil
    var nogginsTouchedSinceLastGrab: [SKShapeNode] = [SKShapeNode]()
    
    init(scene: BaseScene) {
        super.init(texture: standardTexture)
        self.setRandomPosition()
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!,
                                           size: CGSize(width: self.size.width,
                                                        height: self.size.height))
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.collisionBitMask = GameplayScene.floorCategoryBitMasks.randomElement()! | GameplayScene.wallCategoryBitMask | Person.categoryBitMask
        self.physicsBody?.categoryBitMask = HotDog.categoryBitMask
        self.physicsBody?.isDynamic = false
        
        self.zPosition = GameplayScene.spriteZPositions["HotDog"]!
        self.setScene(scene: scene)
        
        self.countdownIndicator.setZ(zPos: self.zPosition)
        self.countdownIndicator.setScene(scene: scene)
        self.countdownIndicator.setHidden(hidden: true)
    
        self.helpIndicator = BaseSprite(imageNamed: "Drag_Overlay_1.png")
        self.helpIndicator?.zPosition = self.zPosition
        self.helpIndicator?.setScene(scene: scene)
        self.helpIndicator?.isHidden = true
        self.helpIndicator?.run(SKAction.repeatForever(SKAction.animate(with: (self._scene as! GameplayScene).helpDragFrames,
                                                                        timePerFrame: 0.1, resize: true, restore: false)))
        
        let appearAnimation: SKAction = SKAction.sequence([
            SKAction.animate(with: (self._scene as! GameplayScene).hotDogAppearFrames,
                             timePerFrame: 0.1, resize: true, restore: true),
            SKAction.run { self.physicsBody?.isDynamic = true } ])
        self.run(appearAnimation)
        
        self.color = .red
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func update(currentTime: TimeInterval) {
        self.updateTexture()
        self.updateCountdown(currentTime: currentTime)
        self.updateHelpIndicator()
        self.resolveGroundDeathConditions(currentTime: currentTime)
        self.resolveRestConditions(currentTime: currentTime)
    }
    
    func resolveRestConditions(currentTime: TimeInterval) {
        if self.previousFloorContactTimes.count != 0 && currentTime - self.previousFloorContactTimes.first! > 0.6 {
            self.countdownIndicator.setHidden(hidden: false)
            self.physicsBody?.isDynamic = false
        }
    }
    
    func resolveGroundDeathConditions(currentTime: TimeInterval) {
        let timeSinceGrab: TimeInterval = currentTime - self.lastGrabTime
        if self.previousFloorContactTimes.count != 0 && !self.isGrabbed && timeSinceFloorContact > 3 && timeSinceGrab > 3 &&
            self.action(forKey: "ground-death") == nil
        {
            self.countdownIndicator.setHidden(hidden: true)
            let groundDieAnimation: SKAction = SKAction.sequence([
                SKAction.animate(with: (self._scene as! GameplayScene).hotDogGroundDeathFrames,
                                 timePerFrame: 0.15, resize: true, restore: false),
                SKAction.run { self.shouldBeDespawned = true }])
            self.run(groundDieAnimation, withKey: "ground-death")
        }
    }
    
    func updateTexture() {
        if self.hasActions() {
            return
        }
        if (self.isGrabbed && self.texture != grabbingTexture) {
            self.texture = grabbingTexture
        } else if (!self.isGrabbed) {
            if ((self.physicsBody?.velocity.dy)! < -10 && self.texture != fallingTexture) {
                self.texture = fallingTexture
            } else if ((self.physicsBody?.velocity.dy)! > 10 && self.texture != risingTexture) {
                self.texture = risingTexture
            } else if (self.texture != standardTexture) {
                self.texture = standardTexture
            }
        }
        self.size = CGSize(width: self.texture!.size().width * self._scene!.scaleFactor,
                           height: self.texture!.size().height * self._scene!.scaleFactor)
    }
    
    func updateHelpIndicator() {
        self.helpIndicator!.position = CGPoint(x: self.position.x, y: self.position.y + 60 * self._scene!.scaleFactor)
        let __scene: GameplayScene = self._scene as! GameplayScene
        if __scene.hotDogsDropped > 0 && __scene.timesAnyNogginWasTopped < GameplayScene.howManyInteractionsToHelpWith && !__scene.aHotDogIsGrabbed && !self.physicsBody!.isDynamic {
            helpIndicator?.isHidden = false
        } else {
            helpIndicator?.isHidden = true
        }
    }
    
    func updateCountdown(currentTime: TimeInterval) {
        self.timeSinceFloorContact = currentTime - ((self.previousFloorContactTimes.last != nil) ? self.previousFloorContactTimes.last! : -1)
        let lifespanSeconds: CGFloat = 3
        let secondsRemaining: Int = max(Int(lifespanSeconds) - Int(self.timeSinceFloorContact), 1)
        let text: String = String(secondsRemaining)
        if self.countdownIndicator.text != text {
            self.countdownIndicator.setText(text: text)
        }
        self.countdownIndicator.setPosition(pos: CGPoint(x: self.position.x + self.calculateAccumulatedFrame().width / 4,
                                                         y: self.position.y + 10 * self._scene!.scaleFactor))
        if self.previousFloorContactTimes.count != 0 {
            self.colorBlendFactor = self.timeSinceFloorContact / lifespanSeconds
        }
    }
    
    func contactedFloor(currentTime: TimeInterval) {
        self.previousFloorContactTimes.append(currentTime)
    }
    
    func contactedPerson(currentTime: TimeInterval, contactedNode: SKShapeNode) {
        self.nogginsTouchedSinceLastGrab.append(contactedNode)
    }
    
    func grab(currentTime: TimeInterval) {
        if !self.hasActions() {
            self.isGrabbed = true
            self.lastGrabTime = currentTime
            self.previousFloorContactTimes = [TimeInterval]()
            self.physicsBody?.isDynamic = false
            self.countdownIndicator.setHidden(hidden: true)
            self.colorBlendFactor = 0
            self.nogginsTouchedSinceLastGrab = [SKShapeNode]()
        }
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
    
    override func cleanup() {
        super.cleanup()
        self.countdownIndicator.cleanup()
        self.countdownIndicator.removeFromParent()
        self.helpIndicator?.removeFromParent()
    }
}
