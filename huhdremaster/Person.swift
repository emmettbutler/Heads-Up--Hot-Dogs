import SpriteKit

class Person: BaseSprite {
    let standardTexture: SKTexture = SKTexture(imageNamed: "dog54x12.png")
    var head: BaseSprite? = nil
    var body: BaseSprite? = nil
    var headOffset: CGFloat = 0
    
    init(scene: BaseScene) {
        super.init(texture: standardTexture)
        
        self.zPosition = GameplayScene.spriteZPositions["Person"]!
        
        body = BaseSprite(imageNamed: "BusinessMan_Idle_1.png")
        body!.setScene(scene: scene)
        body?.zPosition = self.zPosition
        head = BaseSprite(imageNamed: "BusinessHead_Idle_NoDog.png")
        head!.setScene(scene: scene)
        head?.zPosition = self.zPosition + 1
        
        self.position = CGPoint(
            x: 0,
            y: (scene as! GameplayScene).highestFloor!.position.y + (body?.calculateAccumulatedFrame().height)! / 2
        )
        body!.position = self.position
        
        headOffset = (body?.calculateAccumulatedFrame().height)! / 2 + (head?.calculateAccumulatedFrame().height)! / 2 - 10 * scene.scaleFactor
        head?.position = CGPoint(x: body!.position.x, y: body!.position.y + headOffset)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func update(currentTime: TimeInterval) {
    }
    
    override func cleanup() {
        super.cleanup()
    }
}
