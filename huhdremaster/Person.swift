import SpriteKit

class Person: BaseSprite {
    let standardTexture: SKTexture = SKTexture(imageNamed: "dog54x12.png")
    let randomSeed: Int = Int.random(in: 1 ... 10)
    var head: BaseSprite? = nil
    var body: BaseSprite? = nil
    var alternateHead: BaseSprite? = nil
    var headOffset: CGFloat = 0
    static let categoryBitMask: UInt32 = 0b100000
    var helpIndicator: BaseSprite? = nil
    var heartEmitter: SKEmitterNode = SKEmitterNode(fileNamed: "HeartParticles.sks")!
    var headCollider: SKShapeNode? = nil
    var headHotDogDetector: SKShapeNode? = nil
    var previousHotDogContactTimes: [TimeInterval] = [TimeInterval]()
    var hotDogsCurrentlyOnHead: [HotDog] = [HotDog]()
    static let slug: String = "businessman"
    var textureMap: CharacterTextureMap? = nil
    var pointTallyTimes: [TimeInterval] = [TimeInterval]()
    var pointNotification: BaseSprite? = nil
    var walkSpeed: CGFloat = 50.0
    var spawnXSign: Int = 1
    var idleStartTime: TimeInterval = -1
    var isIdling: Bool = false
    var walkHeadAnimation: SKAction? = nil
    var walkAlternateHeadAnimation: SKAction? = nil
    var walkBodyAnimation: SKAction? = nil
    
    init(scene: BaseScene, textureLoader: CharacterTextureLoader) {
        super.init(texture: standardTexture)
        self._scene = scene
        
        self.zPosition = GameplayScene.spriteZPositions["Person"]!
        
        textureMap = textureLoader.getTextureMapBySlug(slug: type(of:self).slug)
        
        body = BaseSprite(texture: textureMap!.idleBodyFrames[0])
        body!.setScene(scene: scene)
        body?.zPosition = self.zPosition
        walkBodyAnimation = SKAction.repeatForever(SKAction.animate(with: textureMap!.walkBodyFrames, timePerFrame: 0.1))
        self.body?.run(walkBodyAnimation!)
        
        head = BaseSprite(texture: textureMap!.idleHeadFrames[0])
        head!.setScene(scene: scene)
        head?.zPosition = self.zPosition + 1
        walkHeadAnimation = SKAction.repeatForever(SKAction.animate(with: textureMap!.walkHeadFrames, timePerFrame: 0.1))
        self.head?.run(walkHeadAnimation!)
        
        alternateHead = BaseSprite(texture: textureMap!.idleHeadFrames[0])
        alternateHead!.setScene(scene: scene)
        alternateHead?.zPosition = self.zPosition + 1
        walkAlternateHeadAnimation = SKAction.repeatForever(SKAction.animate(with: textureMap!.walkHotDogHeadFrames, timePerFrame: 0.1))
        self.alternateHead?.run(walkAlternateHeadAnimation!)
        alternateHead?.isHidden = true
        
        headOffset = (body?.calculateAccumulatedFrame().height)! / 2 + (head?.calculateAccumulatedFrame().height)! / 2 - 10 * scene.scaleFactor
        
        spawnHeadCollider()
        
        self.helpIndicator = BaseSprite(imageNamed: "Drop_Overlay_1.png")
        self.helpIndicator?.zPosition = GameplayScene.spriteZPositions["Notification"]!
        self.helpIndicator?.setScene(scene: scene)
        self.helpIndicator?.isHidden = true
        self.helpIndicator?.run(SKAction.repeatForever(SKAction.animate(with: (self._scene as! GameplayScene).helpDropFrames,
                                                                        timePerFrame: 0.1, resize: true, restore: false)))
        
        heartEmitter.particleBirthRate = 0
        heartEmitter.zPosition = GameplayScene.spriteZPositions["Notification"]!
        self._scene?.addChild(heartEmitter)
        
        pointNotification = BaseSprite(texture: textureMap!.headContactPointNotifyFrames[0])
        pointNotification?.isHidden = true
        pointNotification?.zPosition = GameplayScene.spriteZPositions["Notification"]!
        pointNotification?.setScene(scene: scene)
        
        spawnXSign = [1, -1].randomElement()!
        head?.xScale = CGFloat(spawnXSign)
        body?.xScale = CGFloat(spawnXSign)
        alternateHead?.xScale = CGFloat(spawnXSign)
        let minY: Int = Int(UIScreen.main.bounds.height) / -2 + Int((body?.calculateAccumulatedFrame().height)!) / 2 + Int(getHeadColliderOffsetFromBody())
        let maxY: Int = Int((scene as! GameplayScene).highestFloor!.position.y) + Int((body?.calculateAccumulatedFrame().height)!) / 2 + Int(getHeadColliderOffsetFromBody())
        let spawnX: Int = (Int(UIScreen.main.bounds.width) / (spawnXSign * 2)) + Int((body?.calculateAccumulatedFrame().width)!) / (spawnXSign * 2)
        updatePosition(pos: CGPoint(x:spawnX, y:Int.random(in:minY...maxY)), currentTime: 0)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func contactedHotDog(currentTime: TimeInterval, hotDog: HotDog) {
        self.previousHotDogContactTimes.append(currentTime)
        self.pointTallyTimes = [TimeInterval]()
        self.heartEmitter.particleBirthRate = 25
        if (!self.hotDogsCurrentlyOnHead.contains(hotDog)) {
            self.hotDogsCurrentlyOnHead.append(hotDog)
            pointNotification?.isHidden = false
            pointNotification?.removeAllActions()
            pointNotification?.run(SKAction.sequence([SKAction.animate(with: textureMap!.headContactPointNotifyFrames, timePerFrame: 0.05),
                                                      SKAction.run({self.pointNotification?.isHidden = true})]))
        }
    }
    
    func hideHelpIndicator() {
        helpIndicator?.isHidden = true
    }
    
    func showHelpIndicator() {
        let __scene: GameplayScene = self._scene as! GameplayScene
        if __scene.timesAnyNogginWasTopped < 2 {
            helpIndicator?.isHidden = false
        }
    }
    
    func spawnHeadCollider() {
        headCollider = SKShapeNode(rectOf: CGSize(width: (self.head?.calculateAccumulatedFrame().width)!, height: 10 * self._scene!.scaleFactor))
        headCollider?.position = self.head!.position
        headCollider?.zPosition = self.zPosition + 5
        headCollider?.userData = ["person": self]
        headCollider?.fillColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 0.1)
        headCollider?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (headCollider?.calculateAccumulatedFrame().width)!,
                                                                      height: (headCollider?.calculateAccumulatedFrame().height)!))
        headCollider?.physicsBody?.isDynamic = true
        headCollider?.physicsBody?.affectedByGravity = false
        headCollider?.physicsBody?.mass = 99999999
        headCollider?.physicsBody?.allowsRotation = false
        headCollider?.physicsBody?.categoryBitMask = Person.categoryBitMask
        headCollider?.physicsBody?.contactTestBitMask = HotDog.categoryBitMask
        headCollider?.physicsBody?.collisionBitMask = 0
        self._scene!.addChild(headCollider!)
        
        headHotDogDetector = SKShapeNode(rectOf: CGSize(width: (self.head?.calculateAccumulatedFrame().width)!, height: 30 * self._scene!.scaleFactor))
        headHotDogDetector?.zPosition = headCollider!.zPosition
        headHotDogDetector?.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.1)
        self._scene!.addChild(headHotDogDetector!)
    }
    
    func update(currentTime: TimeInterval) {
        updateHeartEmitter(currentTime: currentTime)
        countHotDogsOnHead()
        updateFace()
        resolvePointsForHeldHotDogs(currentTime: currentTime)
        updatePosition(pos: nil, currentTime: currentTime)
        evaluateDespawnConditions()
        evaluateIdleConditions(currentTime: currentTime)
    }
    
    func evaluateIdleConditions(currentTime: TimeInterval) {
        if abs(self.position.x) < UIScreen.main.bounds.width / 4 && Int.random(in: 1 ... 100) == 1 && idleStartTime == -1 {
            idleStartTime = currentTime
            isIdling = true
            self.headCollider?.physicsBody?.velocity.dx = 0
            self.headCollider?.physicsBody?.velocity.dy = 0
            self.body?.run(SKAction.repeatForever(SKAction.animate(with: textureMap!.idleBodyFrames, timePerFrame: 0.1)))
            self.head?.run(SKAction.repeatForever(SKAction.animate(with: textureMap!.idleHeadFrames, timePerFrame: 0.1)))
            self.alternateHead?.run(SKAction.repeatForever(SKAction.animate(with: textureMap!.idleHotDogHeadFrames, timePerFrame: 0.1)))
        } else if (isIdling) {
            if currentTime - idleStartTime >= 5 {
                isIdling = false
                self.body?.run(walkBodyAnimation!)
                self.head?.run(walkHeadAnimation!)
                self.alternateHead?.run(walkAlternateHeadAnimation!)
            }
        }
    }
    
    func getHeadColliderOffsetFromBody() -> CGFloat {
        return headOffset + (self.body?.calculateAccumulatedFrame().height)! / 2 - 10 * (self._scene?.scaleFactor)!
    }
    
    func evaluateDespawnConditions() {
        if abs(self.position.x) > UIScreen.main.bounds.width + (self.head?.calculateAccumulatedFrame().width)! + 100 {
            shouldBeDespawned = true
        }
    }
    
    func applyForce(force: CGVector) {
        headCollider!.physicsBody?.applyForce(force)
        let multiplier: CGFloat = walkSpeed / CGFloat(hypotf(Float((headCollider!.physicsBody?.velocity.dx)!),
                                                             Float((headCollider!.physicsBody?.velocity.dy)!)))
        headCollider!.physicsBody?.velocity.dx *= multiplier
        headCollider!.physicsBody?.velocity.dy *= multiplier
    }
    
    func updatePosition(pos: CGPoint?, currentTime: TimeInterval) {
        if pos != nil {
            headCollider!.position = pos!
        } else if (!isIdling){
            applyForce(force: CGVector(
                dx:self.walkSpeed * CGFloat(self.spawnXSign * -1) * (headCollider!.physicsBody?.mass)!,
                dy:(cos(currentTime + CGFloat(randomSeed)) * 10) * (headCollider!.physicsBody?.mass)!))
        }
        self.position = headCollider!.position
        body?.position = CGPoint(x: self.position.x, y: self.position.y - getHeadColliderOffsetFromBody())
        head?.position = CGPoint(x: body!.position.x, y: body!.position.y + headOffset)
        alternateHead?.position = head!.position
        headHotDogDetector?.position = CGPoint(
            x: (headCollider?.position.x)!,
            y: (headCollider?.position.y)! + (headHotDogDetector?.calculateAccumulatedFrame().height)! / 2
        )
        helpIndicator?.position = CGPoint(
            x: self.position.x,
            y: (self.head?.position.y)! + (self.head?.calculateAccumulatedFrame().height)! / 2 + (self.helpIndicator?.calculateAccumulatedFrame().height)! / 2)
        heartEmitter.position = self.headCollider!.position
        pointNotification?.position = headCollider!.position
        pointNotification?.size = CGSize(width: (pointNotification?.texture!.size().width)! * self._scene!.scaleFactor,
                                         height: (pointNotification?.texture!.size().height)! * self._scene!.scaleFactor)
    }
    
    func resolvePointsForHeldHotDogs(currentTime: TimeInterval) {
        let bucketedTime: CGFloat = (currentTime - (previousHotDogContactTimes.last ?? currentTime)).rounded()
        if self.hotDogsCurrentlyOnHead.count > 0 && !pointTallyTimes.contains(bucketedTime) {
            pointTallyTimes.append(bucketedTime)
            (self._scene as! GameplayScene).pointCounter?.points += GameplayScene.pointsForHotDogStayedOnHead * self.hotDogsCurrentlyOnHead.count
            if pointNotification?.hasActions() == false {
                pointNotification?.isHidden = false
                pointNotification?.removeAllActions()
                pointNotification?.run(SKAction.sequence([SKAction.animate(with: textureMap!.heldHotDogsPointNotifyFrames, timePerFrame: 0.05),
                                                          SKAction.run({self.pointNotification?.isHidden = true})]))
            }
        }
    }
    
    func updateHeartEmitter(currentTime: TimeInterval) {
        if self.previousHotDogContactTimes.count != 0 && currentTime - self.previousHotDogContactTimes.last! > 1 {
            heartEmitter.particleBirthRate = 0
        }
    }
    
    func countHotDogsOnHead() {
        for hotDogOnHead in hotDogsCurrentlyOnHead {
            if !(headHotDogDetector?.contains(hotDogOnHead.position))! {
                hotDogsCurrentlyOnHead.remove(at: hotDogsCurrentlyOnHead.firstIndex(of: hotDogOnHead)!)
            }
        }
    }
    
    func updateFace() {
        if hotDogsCurrentlyOnHead.count == 0 {
            head?.isHidden = false
            alternateHead?.isHidden = true
        } else {
            head?.isHidden = true
            alternateHead?.isHidden = false
        }
    }
    
    override func cleanup() {
        super.cleanup()
        body?.removeFromParent()
        head?.removeFromParent()
        alternateHead?.removeFromParent()
        headCollider?.removeFromParent()
        headHotDogDetector?.removeFromParent()
        helpIndicator?.removeFromParent()
        heartEmitter.removeFromParent()
        pointNotification?.removeFromParent()
    }
}
