//
//  HotDog.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/31/22.
//

import SpriteKit

class HotDog: BaseSprite {
    static let categoryBitMask: UInt32 = 0b10000000
    var standardTexture: SKTexture? = nil
    var fallingTexture: SKTexture? = nil
    var risingTexture: SKTexture? = nil
    var grabbingTexture: SKTexture? = nil
    var appearFrames: [SKTexture] = [SKTexture]()
    var groundDeathFrames: [SKTexture] = [SKTexture]()
    var isGrabbed: Bool = false
    var previousDragPosition: CGPoint = CGPoint(x:0, y:0)
    var previousFloorContactTimes: [TimeInterval] = [TimeInterval]()
    var lastGrabTime: TimeInterval = -1
    let countdownIndicator: ShadowedText = ShadowedText()
    var timeSinceFloorContact: TimeInterval = -1
    var helpIndicator: BaseSprite? = nil
    var nogginsTouchedSinceLastGrab: [SKShapeNode] = [SKShapeNode]()
    var everythingCollisionMask: UInt32 = 0
    static let nothingCollisionMask: UInt32 = 0
    var noPeopleCollisionMask: UInt32 = 0
    var noWallsCollisionMask: UInt32 = 0
    
    required init(scene: BaseScene) {
        super.init(imageNamed: "dog54x12.png")
        self.isHidden = true
        self.setScene(scene: scene)
    }
    
    func buildSprites() {
        let randomFloorMask: UInt32 = GameplayScene.floorCategoryBitMasks.randomElement()!
        everythingCollisionMask = randomFloorMask | GameplayScene.wallCategoryBitMask | Person.categoryBitMask
        noPeopleCollisionMask = randomFloorMask
        noWallsCollisionMask = randomFloorMask | Person.categoryBitMask
        
        self.setRandomPosition()
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!,
                                           size: CGSize(width: self.size.width,
                                                        height: self.size.height))
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.collisionBitMask = noPeopleCollisionMask
        self.physicsBody?.categoryBitMask = HotDog.categoryBitMask
        self.physicsBody?.isDynamic = false
        
        self.zPosition = GameplayScene.spriteZPositions["HotDog"]!
        
        self.countdownIndicator.setZ(zPos: self.zPosition)
        self.countdownIndicator.setScene(scene: _scene!)
        self.countdownIndicator.setHidden(hidden: true)
    
        self.helpIndicator = BaseSprite(imageNamed: "Drag_Overlay_1.png")
        self.helpIndicator?.zPosition = self.zPosition
        self.helpIndicator?.setScene(scene: _scene!)
        self.helpIndicator?.isHidden = true
        self.helpIndicator?.run(SKAction.repeatForever(SKAction.animate(with: (self._scene as! GameplayScene).helpDragFrames,
                                                                        timePerFrame: 0.1, resize: true, restore: false)))
        
        let appearAnimation: SKAction = SKAction.sequence([
            SKAction.animate(with: appearFrames, timePerFrame: 0.1, resize: true, restore: true),
            SKAction.run { self.physicsBody?.isDynamic = true } ])
        self.run(appearAnimation)
        
        self.color = .red
        self.isHidden = false
    }
    
    override func cleanup() {
        super.cleanup()
        self.countdownIndicator.cleanup()
        self.countdownIndicator.removeFromParent()
        self.helpIndicator?.removeFromParent()
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
                SKAction.animate(with: groundDeathFrames, timePerFrame: 0.15, resize: true, restore: false),
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
        if __scene.hotDogsDropped > 0 && __scene.timesAnyNogginWasTopped < GameplayScene.howManyInteractionsToHelpWith && !__scene.aHotDogIsGrabbed && !self.physicsBody!.isDynamic && !self.hasActions() {
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
        self.physicsBody?.collisionBitMask = everythingCollisionMask
    }
    
    func contactedPerson(currentTime: TimeInterval, contactedNode: SKShapeNode) {
        if (self.physicsBody!.collisionBitMask & Person.categoryBitMask == 0) { return }
        self.nogginsTouchedSinceLastGrab.append(contactedNode)
        self.physicsBody?.collisionBitMask = noWallsCollisionMask
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
            self.physicsBody?.collisionBitMask = HotDog.nothingCollisionMask
        }
    }
    
    func releaseGrab() {
        self.isGrabbed = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.applyImpulse(CGVector(dx:self.position.x - self.previousDragPosition.x,
                                                dy: self.position.y - self.previousDragPosition.y))
        self.physicsBody?.collisionBitMask = everythingCollisionMask
    }
    
    func drag(toPos: CGPoint) {
        if self.isGrabbed {
            self.previousDragPosition = self.position
            self.position = toPos
        }
    }
}

class BasicHotDog: HotDog {
    required init(scene: BaseScene) {
        super.init(scene: scene)
        standardTexture = SKTexture(imageNamed: "dog54x12.png")
        fallingTexture = SKTexture(imageNamed: "Dog_Fall.png")
        risingTexture = SKTexture(imageNamed: "Dog_Rise.png")
        grabbingTexture = SKTexture(imageNamed: "Dog_Grabbed.png")
        for idx in 1 ... 7 {
            groundDeathFrames.append(SKTexture(imageNamed: NSString(format:"Dog_Die_%d.png", idx) as String))
        }
        for idx in 1 ... 10 {
            appearFrames.append(SKTexture(imageNamed: NSString(format:"Dog_Appear_%d.png", idx) as String))
        }
        buildSprites()
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
}

protocol SpecialHotDog: HotDog {
    var doAppearAnimation: Int { get }
}

extension SpecialHotDog {
    var doAppearAnimation: Int {
        for idx in 1 ... 6 {
            appearFrames.append(SKTexture(imageNamed: NSString(format:"BonusAppear%d.png", idx) as String))
        }
        return 0
    }
}

class Cheesesteak: HotDog, SpecialHotDog {
    required init(scene: BaseScene) {
        super.init(scene: scene)
        standardTexture = SKTexture(imageNamed: "Steak.png")
        fallingTexture = SKTexture(imageNamed: "Steak_Fall.png")
        risingTexture = SKTexture(imageNamed: "Steak_Rise.png")
        grabbingTexture = SKTexture(imageNamed: "Steak_Grabbed.png")
        for idx in 1 ... 7 {
            groundDeathFrames.append(SKTexture(imageNamed: NSString(format:"Steak_Die_%d.png", idx) as String))
        }
        doAppearAnimation
        buildSprites()
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
}
