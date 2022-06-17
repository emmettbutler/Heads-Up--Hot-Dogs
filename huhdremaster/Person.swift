import SpriteKit

class Person: BaseSprite {
    let standardTexture: SKTexture = SKTexture(imageNamed: "dog54x12.png")
    var head: BaseSprite? = nil
    var body: BaseSprite? = nil
    var headOffset: CGFloat = 0
    static let categoryBitMask: UInt32 = 0b0101
    var helpIndicator: BaseSprite? = nil
    var heartEmitter: SKEmitterNode = SKEmitterNode(fileNamed: "HeartParticles.sks")!
    let headCollider: SKShapeNode = SKShapeNode()
    var previousHotDogContactTimes: [TimeInterval] = [TimeInterval]()
    static let slug: String = "businessman"
    var textureMap: CharacterTextureMap? = nil
    
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
        
        self.position = CGPoint(
            x: 0,
            y: (scene as! GameplayScene).highestFloor!.position.y + (body?.calculateAccumulatedFrame().height)! / 2
        )
        body!.position = self.position
        
        headOffset = (body?.calculateAccumulatedFrame().height)! / 2 + (head?.calculateAccumulatedFrame().height)! / 2 - 10 * scene.scaleFactor
        head?.position = CGPoint(x: body!.position.x, y: body!.position.y + headOffset)
        
        spawnHeadCollider()
        
        self.helpIndicator = BaseSprite(imageNamed: "Drop_Overlay_1.png")
        self.helpIndicator?.zPosition = self.zPosition
        self.helpIndicator?.setScene(scene: scene)
        self.helpIndicator?.isHidden = true
        self.helpIndicator?.run(SKAction.repeatForever(SKAction.animate(with: (self._scene as! GameplayScene).helpDropFrames,
                                                                        timePerFrame: 0.1, resize: true, restore: false)))
        self.helpIndicator?.position = CGPoint(x: self.position.x, y: (self.head?.position.y)! + (self.head?.calculateAccumulatedFrame().height)! / 2 + (self.helpIndicator?.calculateAccumulatedFrame().height)! / 2)
        
        heartEmitter.particleBirthRate = 0
        heartEmitter.zPosition = self.zPosition + 3
        self._scene?.addChild(heartEmitter)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func contactedHotDog(currentTime: TimeInterval) {
        self.previousHotDogContactTimes.append(currentTime)
        self.heartEmitter.particleBirthRate = 25
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
        let pathToDraw = CGMutablePath()
        headCollider.position = CGPoint(x: (self.head?.position.x)!,
                                        y: (self.head?.position.y)! + (self.head?.calculateAccumulatedFrame().height)! / 2 - 10 * (self._scene?.scaleFactor)!)
        let startPoint = CGPoint(x: (self.head?.calculateAccumulatedFrame().width)! / -2,
                                 y: 0)
        pathToDraw.move(to: CGPoint(x: startPoint.x, y: 0))
        pathToDraw.addLine(to: CGPoint(x: (self.head?.calculateAccumulatedFrame().width)! / 2, y: 0))
        headCollider.zPosition = self.zPosition + 5
        headCollider.userData = ["person": self]
        headCollider.physicsBody = SKPhysicsBody(edgeChainFrom: pathToDraw)
        headCollider.physicsBody?.isDynamic = false
        headCollider.physicsBody?.categoryBitMask = Person.categoryBitMask
        headCollider.physicsBody?.contactTestBitMask = HotDog.categoryBitMask
        self._scene!.addChild(headCollider)
    }
    
    func update(currentTime: TimeInterval) {
        if self.previousHotDogContactTimes.count != 0 && currentTime - self.previousHotDogContactTimes.last! > 1 {
            heartEmitter.particleBirthRate = 0
        }
        heartEmitter.position = self.headCollider.position
    }
    
    override func cleanup() {
        super.cleanup()
    }
}
