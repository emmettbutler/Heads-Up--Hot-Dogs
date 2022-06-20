import SpriteKit

class Person: BaseSprite {
    let standardTexture: SKTexture = SKTexture(imageNamed: "dog54x12.png")
    var head: BaseSprite? = nil
    var body: BaseSprite? = nil
    var headOffset: CGFloat = 0
    static let categoryBitMask: UInt32 = 0b0101
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
    
    init(scene: BaseScene, textureLoader: CharacterTextureLoader) {
        super.init(texture: standardTexture)
        self._scene = scene
        
        self.zPosition = GameplayScene.spriteZPositions["Person"]!
        
        textureMap = textureLoader.getTextureMapBySlug(slug: type(of:self).slug)
        
        body = BaseSprite(texture: textureMap!.idleBodyFrames[0])
        body!.setScene(scene: scene)
        body?.zPosition = self.zPosition
        let idleBodyFrames: [SKTexture] = textureMap!.idleBodyFrames
        self.body?.run(SKAction.repeatForever(SKAction.animate(with: idleBodyFrames, timePerFrame: 0.1)))
        
        head = BaseSprite(texture: textureMap!.idleHeadFrames[0])
        head!.setScene(scene: scene)
        head?.zPosition = self.zPosition + 1
        
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
        let minY: Int = Int(UIScreen.main.bounds.height) / -2 + Int((body?.calculateAccumulatedFrame().height)!) / 2 + Int(getHeadColliderOffsetFromBody())
        let maxY: Int = Int((scene as! GameplayScene).highestFloor!.position.y) + Int((body?.calculateAccumulatedFrame().height)!) / 2 + Int(getHeadColliderOffsetFromBody())
        let spawnX: Int = (Int(UIScreen.main.bounds.width) / (spawnXSign * 2)) + Int((body?.calculateAccumulatedFrame().width)!) / (spawnXSign * 2)
        updatePosition(pos: CGPoint(x:spawnX, y:Int.random(in:minY...maxY)))
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
        headCollider?.fillColor = .red
        headCollider?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (headCollider?.calculateAccumulatedFrame().width)!,
                                                                      height: (headCollider?.calculateAccumulatedFrame().height)!))
        headCollider?.physicsBody?.isDynamic = true
        headCollider?.physicsBody?.affectedByGravity = false
        headCollider?.physicsBody?.mass = 99999999
        headCollider?.physicsBody?.allowsRotation = false
        headCollider?.physicsBody?.categoryBitMask = Person.categoryBitMask
        headCollider?.physicsBody?.contactTestBitMask = HotDog.categoryBitMask
        headCollider?.physicsBody?.collisionBitMask = HotDog.categoryBitMask
        self._scene!.addChild(headCollider!)
        
        headHotDogDetector = SKShapeNode(rectOf: CGSize(width: (self.head?.calculateAccumulatedFrame().width)!, height: 30 * self._scene!.scaleFactor))
        headHotDogDetector?.zPosition = headCollider!.zPosition
        headHotDogDetector?.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self._scene!.addChild(headHotDogDetector!)
    }
    
    func update(currentTime: TimeInterval) {
        updateHeartEmitter(currentTime: currentTime)
        countHotDogsOnHead()
        updateFace()
        resolvePointsForHeldHotDogs(currentTime: currentTime)
        self.pointNotification?.size = CGSize(width: (self.pointNotification?.texture!.size().width)! * self._scene!.scaleFactor,
                                              height: (self.pointNotification?.texture!.size().height)! * self._scene!.scaleFactor)
        updatePosition(pos: nil)
    }
    
    func getHeadColliderOffsetFromBody() -> CGFloat {
        return headOffset + (self.body?.calculateAccumulatedFrame().height)! / 2 - 10 * (self._scene?.scaleFactor)!
    }
    
    func updatePosition(pos: CGPoint?) {
        if pos != nil {
            headCollider!.position = pos!
        } else {
            headCollider!.physicsBody?.applyForce(CGVector(dx:self.walkSpeed * CGFloat(self.spawnXSign * -1) * (headCollider!.physicsBody?.mass)!, dy:0))
            let multiplier: CGFloat = walkSpeed / CGFloat(hypotf(Float((headCollider!.physicsBody?.velocity.dx)!), Float((headCollider!.physicsBody?.velocity.dy)!)))
            headCollider!.physicsBody?.velocity.dx *= multiplier
            headCollider!.physicsBody?.velocity.dy *= multiplier
        }
        self.position = headCollider!.position
        body?.position = CGPoint(x: self.position.x, y: self.position.y - getHeadColliderOffsetFromBody())
        head?.position = CGPoint(x: body!.position.x, y: body!.position.y + headOffset)
        headHotDogDetector?.position = CGPoint(
            x: (headCollider?.position.x)!,
            y: (headCollider?.position.y)! + (headHotDogDetector?.calculateAccumulatedFrame().height)! / 2
        )
        helpIndicator?.position = CGPoint(
            x: self.position.x,
            y: (self.head?.position.y)! + (self.head?.calculateAccumulatedFrame().height)! / 2 + (self.helpIndicator?.calculateAccumulatedFrame().height)! / 2)
        heartEmitter.position = self.headCollider!.position
        pointNotification?.position = headCollider!.position
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
            head?.texture = textureMap?.idleHeadFrames[0]
        } else {
            head?.texture = textureMap?.idleHotDogHeadFrames[0]
        }
    }
    
    override func cleanup() {
        super.cleanup()
    }
}
