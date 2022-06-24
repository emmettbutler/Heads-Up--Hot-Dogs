import SpriteKit

class HeadsUpDisplay: BaseSprite {
    let backgroundTexture: SKTexture = SKTexture(imageNamed: "DogHud_BG.png")
    let hotDogTexture: SKTexture = SKTexture(imageNamed: "DogHud_Dog.png")
    var xTextures: [SKTexture] = [SKTexture]()
    var indicators: [BaseSprite] = [BaseSprite]()
    var subtractAnimation: SKAction? = nil
    static let _zPosition: CGFloat = 60
    
    init(scene: BaseScene) {
        super.init(texture: backgroundTexture)
        self.setScene(scene: scene)
        
        self.zPosition = HeadsUpDisplay._zPosition
        self.position = CGPoint(x: 0, y: UIScreen.main.bounds.height / 2 - 50 * scene.scaleFactor)
        
        for idx in (-2 ... 2).reversed() {
            let indicator = BaseSprite(texture: hotDogTexture)
            indicator.setScene(scene: scene)
            indicator.zPosition = self.zPosition + 1
            indicator.position = CGPoint(
                x: self.position.x + (CGFloat(idx) * (indicator.calculateAccumulatedFrame().width + 7 * scene.scaleFactor)),
                y: self.position.y)
            indicators.append(indicator)
        }
        
        for idx in 1 ... 6 {
            xTextures.append(SKTexture(imageNamed: NSString(format: "DogHud_X_%d.png", idx) as String))
        }
        
        subtractAnimation = SKAction.animate(with: self.xTextures, timePerFrame: 0.15, resize: true, restore: false)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func subtract() {
        for idx in 0 ... 4 {
            if self.indicators[idx].texture == hotDogTexture {
                self.indicators[idx].run(self.subtractAnimation!)
                break
            }
        }
    }
    
    func add() {
        for idx in (0 ... 4).reversed() {
            if self.indicators[idx].texture == xTextures.last {
                self.indicators[idx].texture = hotDogTexture
                self.indicators[idx].size = hotDogTexture.size()
                break
            }
        }
    }
}

class PointCounter: BaseSprite {
    let backgroundTexture: SKTexture = SKTexture(imageNamed: "Score_BG.png")
    let pointsText: BaseText = BaseText()
    var points: Int = 0
    
    init(scene: BaseScene) {
        super.init(texture: backgroundTexture)
        self.setScene(scene: scene)
        self.position = CGPoint(x: UIScreen.main.bounds.width / 2 - self.calculateAccumulatedFrame().width / 2 - 20 * (scene as! GameplayScene).scaleFactor,
                                y: UIScreen.main.bounds.height / 2 - self.calculateAccumulatedFrame().height / 2 - 20 * (scene as! GameplayScene).scaleFactor)
        self.zPosition = HeadsUpDisplay._zPosition
        
        pointsText.zPosition = self.zPosition + 1
        pointsText.text = NSString(format: "%07d", self.points) as String
        pointsText.position = CGPoint(x: self.position.x + self.calculateAccumulatedFrame().width / 2 - 5, y: self.position.y - self.calculateAccumulatedFrame().height / 2)
        pointsText.preferredMaxLayoutWidth = self.calculateAccumulatedFrame().width
        pointsText.horizontalAlignmentMode = .right
        pointsText.fontSize = 40 * (scene as! GameplayScene).scaleFactor
        pointsText.setScene(scene: scene)
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func update(currentTime: TimeInterval) {
        pointsText.text = NSString(format: "%07d", self.points) as String
    }
}
